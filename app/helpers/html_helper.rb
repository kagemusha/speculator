module HtmlHelper

  def block_tag(tag, options = {}, &block)
    #concat(content_tag(tag, capture(&block), options), block.binding)
    content_tag(tag, capture(&block), options)
  end

  def jqTmpl(id, options={}, &block)
    options[:id] = id
    options[:type] = "text/html"
    block_tag("script", options, &block)
  end


  def elem(tag, val, attrs=nil)
      attrs = hashToAttrs(attrs) if attrs.class == Hash
      hasClose = (val != nil)
      elem = "<#{tag} #{attrs}>" + (hasClose ? "#{val} </#{tag}>" : " />")
      elem.html_safe
  end


  def attr(key, val)
      "#{key}='#{val}' "
  end

  def hashToAttrs(hash)
    attrStr = ""
    hash.each do |key, val|
      attrStr += attr(key, val)
    end
    attrStr
  end

  OBJ_ID_ATTR = "obj_id"
  OBJ_TYPE_ATTR = "obj_type"
  SET_TYPE_ATTR = "set_type"


  def templated_table(tableId, headers, objType, setType, attrs={})
    attrs[:id] = tableId
    attrs[:class] = "#{attrs[:class]} list"
    header = table_header(headers, {:class=>"header"})
    body = elem("tbody","",:id=>"#{tableId}Body", OBJ_TYPE_ATTR=>objType, SET_TYPE_ATTR=>setType)
    elem("table", header+body, attrs)
  end


  def table_header(headings, attrs={})
    ths = ""
    headings.each { |heading| ths += elem("th", heading) }
    elem("thead", elem("tr", ths, attrs))
  end
  def simple_menu_list(links)
    links.join(msep).html_safe
  end

  def button_submit_tag(label, options={})
    options[:class] = "button #{options[:class]}"
    submit_tag label, options
  end

  def button_cancel_tag(label="Cancel", options={})
    options[:class] = "cancel button #{options[:class]}"
    submit_tag label, options
  end

  def back_button(options={})
    options[:class] = "backBtn #{options[:class]}"
    back_link("<", options)
  end

  def back_link(label=nil, options={})
    link_to( (label || "Back"), "back", options)
  end


  def delete_link(label, obj, type=nil, options = {})
    type = type || obj.class.name #fix!!
    options[:objId] = (obj == nil or !obj.respond_to?(:id)) ? obj : obj.id
    #options[:object_type] = type
    options[:class] = "delete #{options[:class]}"
    link_to(label, "#", options)
  end

  def js(function, json="")
    #function += (!function.end_with?("()") ? "()" : "" )
    fn = <<-STR
      <script>
        $(function(){
          var root = window || global;
          root.#{function}(#{json});
        });
      </script>
    STR
    fn.html_safe
  end

  def field_focus(field_id)
    js "$('#{field_id}').focus()"
  end

end
