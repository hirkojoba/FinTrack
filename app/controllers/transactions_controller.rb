class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:edit, :update, :destroy]

  def index
    @transactions = current_user.transactions.recent
  end

  def new
    @transaction = current_user.transactions.build
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    # Auto-categorize if no category provided
    if @transaction.category.blank?
      @transaction.category = auto_categorize(@transaction.description)
    end

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: "Transaction deleted successfully!"
  end

  def upload
    # Render the CSV upload form
  end

  def import
    require 'csv'

    if params[:file].blank?
      redirect_to upload_transactions_path, alert: "Please select a CSV file to upload."
      return
    end

    file = params[:file]

    # Security: Validate file type
    unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
      redirect_to upload_transactions_path, alert: "Please upload a valid CSV file."
      return
    end

    # Security: Limit file size to 5MB
    if file.size > 5.megabytes
      redirect_to upload_transactions_path, alert: "File size exceeds 5MB limit."
      return
    end

    imported_count = 0
    errors = []
    max_rows = 10000  # Prevent DoS from huge files

    begin
      CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
        # Security: Prevent processing too many rows
        if imported_count + errors.length >= max_rows
          errors << "Exceeded maximum of #{max_rows} rows"
          break
        end

        # Expected columns: date, description, amount
        # Optional: category
        transaction = current_user.transactions.build(
          date: row[:date],
          description: row[:description],
          amount: row[:amount],
          category: row[:category]
        )

        # Auto-categorize if no category provided
        if transaction.category.blank?
          transaction.category = auto_categorize(transaction.description)
        end

        if transaction.save
          imported_count += 1
        else
          errors << "Row #{imported_count + errors.length + 1}: #{transaction.errors.full_messages.join(', ')}"
        end
      end

      if errors.any?
        flash[:alert] = "Imported #{imported_count} transactions with #{errors.length} errors: #{errors.first(5).join('; ')}"
      else
        flash[:notice] = "Successfully imported #{imported_count} transactions!"
      end
    rescue CSV::MalformedCSVError => e
      flash[:alert] = "Error parsing CSV file: #{e.message}"
    rescue => e
      flash[:alert] = "Error importing transactions: #{e.message}"
    end

    redirect_to transactions_path
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:date, :description, :amount, :category)
  end

  def auto_categorize(description)
    description_lower = description.downcase

    case description_lower
    when /uber|lyft|taxi|transit|bus|train|metro/
      "Transportation"
    when /starbucks|coffee|restaurant|cafe|food|dining|eat/
      "Eating Out"
    when /grocery|supermarket|market|trader joe|whole foods|safeway/
      "Groceries"
    when /rent|mortgage|lease/
      "Housing"
    when /utility|electric|gas|water|internet|phone|cable/
      "Utilities"
    when /netflix|spotify|hulu|amazon prime|subscription/
      "Entertainment"
    when /gym|fitness|health|doctor|medical|pharmacy/
      "Health & Fitness"
    when /salary|paycheck|income|wage/
      "Income"
    else
      "Uncategorized"
    end
  end
end
