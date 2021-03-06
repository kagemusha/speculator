# RailsAdmin config file. Generated on July 20, 2012 19:08
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, User

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, User

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Speculator', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [BalanceSheet, CashflowStatement, FinancialStatement, IncomeStatement, NewLow, Opinion, Role, Stock, User]

  # Add models here if you want to go 'whitelist mode':
  # config.included_models = [BalanceSheet, CashflowStatement, FinancialStatement, IncomeStatement, NewLow, Opinion, Role, Stock, User]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model BalanceSheet do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :period_type, :text 
  #     configure :period_start, :date 
  #     configure :cash, :float 
  #     configure :st_investments, :float 
  #     configure :acct_rec, :float 
  #     configure :inventories, :float 
  #     configure :tot_cur_assets, :float 
  #     configure :ppe, :float 
  #     configure :land, :float 
  #     configure :lt_investments, :float 
  #     configure :intangible_assets, :float 
  #     configure :tot_cur_liab, :float 
  #     configure :lt_debt, :float 
  #     configure :charge_provision, :float 
  #     configure :tot_liab, :float   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model CashflowStatement do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :period_type, :text 
  #     configure :period_start, :date 
  #     configure :depreciation, :float 
  #     configure :funds_from_ops, :float 
  #     configure :chg_in_working_cap, :float 
  #     configure :op_cf, :float 
  #     configure :capex, :float 
  #     configure :net_acq_assets, :float 
  #     configure :sale_of_fixed_assets, :float 
  #     configure :investments_chg, :float 
  #     configure :invest_cf, :float 
  #     configure :divs_paid, :float 
  #     configure :debt_chg, :float 
  #     configure :finance_cf, :float 
  #     configure :free_cf, :float   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model FinancialStatement do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :period_type, :text 
  #     configure :period_start, :date   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model IncomeStatement do
  #   # Found associations:
  #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :period_type, :text 
  #     configure :period_start, :date 
  #     configure :sales, :float 
  #     configure :cogs, :float 
  #     configure :da_expense, :float 
  #     configure :gross_inc, :float 
  #     configure :sga, :float 
  #     configure :rd, :float 
  #     configure :interest_exp, :float 
  #     configure :tax, :float 
  #     configure :net_inc, :float 
  #     configure :eps_diluted, :float 
  #     configure :ebitda, :float   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model NewLow do
  #   # Found associations:
  #     configure :stock, :belongs_to_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :stock_id, :bson_object_id         # Hidden 
  #     configure :date, :date 
  #     configure :company_name, :text 
  #     configure :new_low_price, :float 
  #     configure :price, :float 
  #     configure :chg, :float 
  #     configure :chg_pct, :float 
  #     configure :vol, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Opinion do
  #   # Found associations:
  #     configure :stock, :belongs_to_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :stock_id, :bson_object_id         # Hidden 
  #     configure :action, :text 
  #     configure :killer, :text 
  #     configure :catalyst, :text 
  #     configure :sales_comments, :text 
  #     configure :pl_comments, :text 
  #     configure :bs_comments, :text 
  #     configure :cf_comments, :text 
  #     configure :credit_rating, :text 
  #     configure :general_comments, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Role do
  #   # Found associations:
  #     configure :users, :has_and_belongs_to_many_association 
  #     configure :resource, :polymorphic_association         # Hidden   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :user_ids, :serialized         # Hidden 
  #     configure :resource_type, :text         # Hidden 
  #     configure :resource_field, :string         # Hidden 
  #     configure :resource_id, :bson_object_id         # Hidden 
  #     configure :name, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Stock do
  #   # Found associations:
  #     configure :new_lows, :has_many_association 
  #     configure :opinions, :has_many_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :symbol, :text 
  #     configure :sector, :text 
  #     configure :exch, :text 
  #     configure :company_name, :text 
  #     configure :industry, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model User do
  #   # Found associations:
  #     configure :roles, :has_and_belongs_to_many_association   #   # Found columns:
  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :role_ids, :serialized         # Hidden 
  #     configure :email, :text 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :text         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :text 
  #     configure :last_sign_in_ip, :text 
  #     configure :name, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end
