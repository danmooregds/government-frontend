class ServiceManualPresenter < ContentItemPresenter
  def links
    @links ||= content_item["links"] || {}
  end

  def details
    @details ||= content_item["details"] || {}
  end

  def include_search_in_header?
    true
  end

  def service_manual?
    true
  end

  def show_phase_banner?
    false
  end
end
