class RelatedListings < ApplicationController


  def search_modes_in_use(q, lc, main_search)
    # lc should be two decimal coordinates separated with a comma
    # e.g. 65.123,-10
    coords_valid = /^-?\d+(?:\.\d+)?,-?\d+(?:\.\d+)?$/.match(lc)
    {
      keyword: q && (main_search == :keyword || main_search == :keyword_and_location),
      location: coords_valid && (main_search == :location || main_search == :keyword_and_location),
    }
  end

  def find_related(params, current_page, listings_per_page, filter_params, includes, location_search_in_use, keyword_search_in_use)
    Maybe(@current_community.categories.find_by_url_or_id(params[:category])).each do |category|
      filter_params[:categories] = category.own_and_subcategory_ids
      @selected_category = category
    end

    filter_params[:search] = params[:q] if params[:q] && keyword_search_in_use
    filter_params[:custom_dropdown_field_options] = HomepageController.dropdown_field_options_for_search(params)
    filter_params[:custom_checkbox_field_options] = HomepageController.checkbox_field_options_for_search(params)

    filter_params[:price_cents] = filter_range(params[:price_min], params[:price_max])

    p = HomepageController.numeric_filter_params(params)
    p = HomepageController.parse_numeric_filter_params(p)
    p = HomepageController.group_to_ranges(p)
    numeric_search_params = HomepageController.filter_unnecessary(p, @current_community.custom_numeric_fields)

    filter_params = filter_params.reject {
      |_, value| (value == "all" || value == ["all"])
    } # all means the filter doesn't need to be included

    checkboxes = filter_params[:custom_checkbox_field_options].map { |checkbox_field| checkbox_field.merge(type: :selection_group, operator: :and) }
    dropdowns = filter_params[:custom_dropdown_field_options].map { |dropdown_field| dropdown_field.merge(type: :selection_group, operator: :or) }
    numbers = numeric_search_params.map { |numeric| numeric.merge(type: :numeric_range) }

    search = {
      # Add listing_id
      categories: filter_params[:categories],
      listing_shape_ids: Array(filter_params[:listing_shape]),
      price_cents: filter_params[:price_cents],
      keywords: filter_params[:search],
      fields: checkboxes.concat(dropdowns).concat(numbers),
      per_page: listings_per_page,
      page: current_page,
      price_min: params[:price_min],
      price_max: params[:price_max],
      locale: I18n.locale,
      include_closed: false,
      sort: nil
    }

    if @view_type != 'map' && location_search_in_use
      search.merge!(location_search_params(params, keyword_search_in_use))
    end

    raise_errors = Rails.env.development?

    ListingIndexService::API::Api.listings.search(
      community_id: @current_community.id,
      search: search,
      includes: includes,
      engine: FeatureFlagHelper.search_engine,
      raise_errors: raise_errors
      ).and_then { |res|
      Result::Success.new(
        if FeatureFlagHelper.search_engine == :discovery
          res
        else
          ListingIndexViewUtils.to_struct(
            result: res,
            includes: includes,
            page: search[:page],
            per_page: search[:per_page]
          )
        end
      )
    }
  end




  def search_related
    filter_params = {}

    listing_shape_param = params[:transaction_type]

    selected_shape = all_shapes.find { |s| s[:name] == listing_shape_param }

    filter_params[:listing_shape] = Maybe(selected_shape)[:id].or_else(nil)

    compact_filter_params = HashUtils.compact(filter_params)

    per_page = @view_type == "map" ? APP_CONFIG.map_listings_limit : APP_CONFIG.grid_listings_limit

    includes =
      case @view_type
      when "grid"
        [:author, :listing_images]
      when "list"
        [:author, :listing_images, :num_of_reviews]
      when "map"
        [:location]
      else
        raise ArgumentError.new("Unknown view_type #{@view_type}")
      end

    main_search = search_mode
    enabled_search_modes = search_modes_in_use(params[:q], params[:lc], main_search)
    keyword_in_use = enabled_search_modes[:keyword]
    location_in_use = enabled_search_modes[:location]

    current_page = Maybe(params)[:page].to_i.map { |n| n > 0 ? n : 1 }.or_else(1)

    search_result = find_related(params, current_page, per_page, compact_filter_params, includes.to_set, location_in_use, keyword_in_use)

    # if @view_type == 'map'
    #   viewport = viewport_geometry(params[:boundingbox], params[:lc], @current_community.location)
    # end

    # if FeatureFlagHelper.search_engine == :discovery
    #   search_result.on_success { |listings|
    #     render layout: "layouts/react_page.haml", template: "search_page/search_page", locals: { bootstrapped_data: listings }
    #   }.on_error {
    #     render nothing: true, status: 500
    #   }
    # elsif request.xhr? # checks if AJAX request
    #   search_result.on_success { |listings|
    #     @listings = listings # TODO Remove

    #     if @view_type == "grid" then
    #       render partial: "grid_item", collection: @listings, as: :listing, locals: { show_distance: location_in_use }
    #     elsif location_in_use
    #       render partial: "list_item_with_distance", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map, show_distance: location_in_use }
    #     else
    #       render partial: "list_item", collection: @listings, as: :listing, locals: { shape_name_map: shape_name_map }
    #     end
    #   }.on_error {
    #     render nothing: true, status: 500
    #   }
    # else
      locals = {
        shapes: all_shapes,
        filters: filters,
        show_price_filter: show_price_filter,
        selected_shape: selected_shape,
        shape_name_map: shape_name_map,
        listing_shape_menu_enabled: listing_shape_menu_enabled,
        main_search: main_search,
        location_search_in_use: location_in_use,
        current_page: current_page,
        current_search_path_without_page: search_path(params.except(:page)),
        viewport: viewport }

      search_result.on_success { |listings|
        Rails.logger.warn "RELATED LISTINGS #{listings}"
        @listings = listings
        render locals: locals.merge(
                 seo_pagination_links: seo_pagination_links(params, @listings.current_page, @listings.total_pages))
      }.on_error { |e|
        flash[:error] = t("homepage.errors.search_engine_not_responding")
        @listings = Listing.none.paginate(:per_page => 1, :page => 1)
        render status: 500,
               locals: locals.merge(
                 seo_pagination_links: seo_pagination_links(params, @listings.current_page, @listings.total_pages))
      }
    # end
  end
 


  def test
  	search(params[:listing_shapes])
  end


 #  def search
	# search_res = if @current_community.private
	#                Result::Success.new({count: 0, listings: []})
	#              else
	#                ListingIndexService::API::Api
	#                  .listings
	#                  .search(
	#                    community_id: @current_community.id,
	#                    search: {
	#                      listing_shape_ids: params[:listing_shapes],
	#                      page: page,
	#                      per_page: per_page
	#                    },
	#                    engine: FeatureFlagHelper.search_engine,
	#                    raise_errors: raise_errors,
	#                    includes: [:listing_images, :author, :location])
	#              end

	# listings = search_res.data[:listings]
 #  end

 #  def new
 #    category_tree = CategoryViewUtils.category_tree(
 #      categories: ListingService::API::Api.categories.get_all(community_id: @current_community.id)[:data],
 #      shapes: get_shapes,
 #      locale: I18n.locale,
 #      all_locales: @current_community.locales
 #    )

 #    render :new, locals: {
 #             categories: @current_community.top_level_categories,
 #             subcategories: @current_community.subcategories,
 #             shapes: get_shapes,
 #             category_tree: category_tree
 #           }
 #  end






 #   = render :partial => "layouts/grid_item_listing_image", :locals => {:listing => listing, :modifier_class => ""}
end	             