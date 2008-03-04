module AppsHelper
  def ext_select_field(options)
    js =  "{"
    js << "  fieldLabel: '#{options[:field_label]}',"
    js << "  xtype: 'combo',"
    js << "  triggerAction: 'all',"
    js << "  typeAhead: true,"
    js << "  forceSelection: true,"
    js << "  transform: '#{options[:existing_select]}',"
    js << "  lazyRender: true,"
    js << "}"

    js
  end

  def ext_hidden_field(options)
    js =  "{"
    js << "  xtype: 'hidden',"
    js << "  name: '#{options[:name]}'"
    js << "}"

    js
  end
end
