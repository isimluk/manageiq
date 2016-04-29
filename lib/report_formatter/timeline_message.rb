module ReportFormatter
  class TimelineMessage
    include CompressedIds

    def initialize(miq_report_instance, row, event, flags)
      @mri = miq_report_instance
      @event, @ems_cloud, @ems_container = event, flags[:ems_cloud], flags[:ems_container]
      @row = row
      @flags = flags
    end

    def vm_name
      "<a href=\"/vm/show/#{to_cid(@event.vm_or_template_id)}\">#{text}</a>" if @event.vm_or_template_id
    end

    def src_vm_name
      "<a href=\"/vm/show/#{to_cid(@event.src_vm_or_template.id)}\">#{text}</a>" if @event.src_vm_or_template
    end

    def dest_vm_name
      "<a href=\"/vm/show/#{to_cid(@event.dest_vm_or_template_id)}\">#{text}</a>" if @event.dest_vm_or_template_id
    end

    def host_name
      "<a href=\"/host/show/#{to_cid(@event.host_id)}\">#{text}</a>" if @event.host_id
    end

    def dest_host_name
      "<a href=\"/host/show/#{to_cid(@event.dest_host_id)}\">#{text}</a>" if @event.dest_host_id
    end

    def ems_cluster_name
      "<a href=\"/ems_cluster/show/#{to_cid(@event.ems_cluster_id)}\">#{text}</a>" if @event.ems_cluster_id
    end

    def availability_zone_name
      if @event.availability_zone_id
        "<a href=\"/availability_zone/show/#{to_cid(@event.availability_zone_id)}\">#{text}</a>"
      end
    end

    def container_node_name
      "<a href=\"/container_node/show/#{to_cid(@event.container_node_id)}\">#{text}</a>" if @event.container_node_id
    end

    def container_group_name
      "<a href=\"/container_group/show/#{to_cid(@event.container_group_id)}\">#{text}</a>" if @event.container_group_id
    end

    def container_name
      "<a href=\"/container/tree_select/?id=cnt-#{to_cid(@event.container_id)}\">#{text}</a>" if @event.container_id
    end

    def container_replicator_name
      if @event.container_replicator_id
        "<a href=\"/container_replicator/show/#{to_cid(@event.container_replicator_id)}\">#{text}</a>"
      end
    end

    def ext_management_system_name
      if @event.ext_management_system && @event.ext_management_system.id
        provider_id = @event.ext_management_system.id
        if @ems_cloud
          # restful route is used for cloud provider unlike infrastructure provider
          "<a href=\"/ems_cloud/#{provider_id}\">#{text}</a>"
        elsif @ems_container
          "<a href=\"/ems_container/#{to_cid(provider_id)}\">#{text}</a>"
        else
          "<a href=\"/ems_infra/#{to_cid(provider_id)}\">#{text}</a>"
        end
      end
    end

    def resource_name
      if @mri.db == 'BottleneckEvent'
        db = if @ems_cloud && @event.resource_type == 'ExtManagementSystem'
               'ems_cloud'
             elsif @event.resource_type == 'ExtManagementSystem'
               'ems_infra'
             else
               @event.resource_type.underscore
             end
        "<a href=\"/#{db}/#{to_cid(@event.resource_id)}\">#{@event.resource_name}</a>"
      end
    end

    def message_html(column)
      @column = column
      field = column.tr('.', '_').to_sym
      respond_to?(field) ? send(field).to_s : text
    end

    private

    def text
      if @row[@column].kind_of?(Time) || TIMELINE_TIME_COLUMNS.include?(@column)
        format_timezone(Time.parse(@row[@column].to_s).utc, @flags[:time_zone], "gtl")
      else
        @row[@column].to_s
      end
    end
  end
end
