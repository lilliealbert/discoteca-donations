class BulkImportsController < ApplicationController
  def new
    authorize :bulk_import
    @events = Event.order(date: :desc)
  end

  def create
    authorize :bulk_import
    if params[:file].blank?
      redirect_to new_bulk_import_path, alert: "Please select a CSV file."
      return
    end

    BulkDonationRequestImport.new(
      params[:file],
      params[:event_id],
      params[:note_prefix]
    ).import

    redirect_to event_path(params[:event_id]), notice: "Donation requests imported successfully."
  rescue StandardError => e
    puts "OH NO IT ALL WENT WRONG"
    puts e.message
    redirect_to new_bulk_import_path, alert: "Import failed: #{e.message}"
  end
end