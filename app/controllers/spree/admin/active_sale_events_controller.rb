module Spree
  module Admin
    class ActiveSaleEventsController < ResourceController
      belongs_to 'spree/active_sale', :find_by => :id
      before_filter :load_active_sale, :only => [:index]
      before_filter :parent_id_for_event, :only => [:new, :edit, :create, :update]
      update.before :get_eventable
      respond_to :json, :only => [:update_events]

      def show
        redirect_to( :action => :edit )
      end

      def destroy
        @active_sale_event = Spree::ActiveSaleEvent.find(params[:id])
        @active_sale_event.destroy
        respond_with(@active_sale_event) { |format| format.json { render :json => '' } }
      end

      def update_events
        @active_sale_event.update_attributes(params[:active_sale_event])
        respond_with(@active_sale_event)
    end
    
          def sort_sales
          @active_sale_event = Spree::ActiveSaleEvent.find(params[:id])
          @sales=@active_sale_event.children.select { |f| f  if f.live? && f.is_active? && !f.is_hidden?}.sort_by{|e| e[:position]} if @active_sale_event.present?
      end
      
      
      def sort_update_sales
          @active_sale_event = Spree::ActiveSaleEvent.find(params[:id])
          @sales=@active_sale_event.children.select { |f| f  if f.live? && f.is_active? && !f.is_hidden?}.sort_by{|e| e[:position]} if @active_sale_event.present?
          sale_ids_positions = params[:sale_positions].split(",").reject(&:blank?).map(&:to_i)
          sale_ids_positions.each_with_index do |id, index|
          sales = @sales.detect{|p| p.id == id }
          sales.update_attributes(:position => index) unless sales.nil?
        end
        redirect_to sort_sales_path(params[:active_sale_id], @active_sale_event.id), :notice => t(:sort_products_taxons_update_message)
      end

      def designer_sort_update_sales
          @taxon = Spree::Taxon.find_by_name('designers')
          @active_sale_event = @taxon.active_sale_events.first
          puts @sales = Spree::ActiveSaleEvent.live_active_and_hidden(:hidden => false).where(:is_designer => true).order( 'start_date DESC' ).sort_by{|e| e[:designer_position]}
          sale_ids_positions = params[:sale_positions].split(",").reject(&:blank?).map(&:to_i)
          sale_ids_positions.each_with_index do |id, index|
          sales = @sales.detect{|p| p.id == id }
          sales.update_attributes(:designer_position => index) unless sales.nil?
        end
        redirect_to designers_path, :notice => t(:sort_products_taxons_update_message)
      end

      private
        def location_after_save
          edit_admin_active_sale_active_sale_event_url(@active_sale_event.active_sale, @active_sale_event, :parent_id => @active_sale_event.parent_id)
        end

      protected

        def collection
          return @collection if @collection.present?
          @search = Spree::ActiveSaleEvent.where(:active_sale_id => params[:active_sale_id]).ransack(params[:q])
          @collection = @search.result.page(params[:page]).per(Spree::ActiveSaleConfig[:admin_active_sale_events_per_page])
        end

        def load_active_sale
          @active_sale = Spree::ActiveSale.find(params[:active_sale_id])
        end

        def build_resource
          get_eventable unless params[object_name].nil?
          if parent_data.present?
            parent.send(controller_name).build(params[object_name])
          else
            model_class.new(params[object_name])
          end
        end

        def get_eventable
          object_name = params[:active_sale_event]
          get_eventable_object(object_name)
        end

        def parent_id_for_event
          params[:parent_id] ||= check_active_sale_event_params
          @parent_id = params[:parent_id]
          if @parent_id.blank?
            redirect_to edit_admin_active_sale_path(params[:active_sale_id]), :notice => I18n.t('spree.active_sale.event.parent_id_cant_be_nil')
          end
        end

        def check_active_sale_event_params(event = params[:active_sale_event])
          return nil if event.nil?
          parent_id = event[:parent_id]
          event.delete(:parent_id) if event[:parent_id].nil? || event[:parent_id] == "nil"
          parent_id
        end
    end
  end
end
