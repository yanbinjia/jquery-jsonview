class JSONFormatter
  htmlEncode: (html) ->
    if html != null
      html.toString()
        .replace(/&/g,"&amp;")
        .replace(/"/g,"&quot;")
        .replace(/</g,"&lt;")
        .replace(/>/g,"&gt;")
    else
      ''

  # Completely escape a json string
  jsString: (s) ->
    s = JSON.stringify(s).slice(1, -1)
    @htmlEncode(s)

  decorateWithSpan: (value, className) ->
    """
    <span class="#{className}">#{@htmlEncode(value)}</span>
    """

  # Convert a basic JSON datatype (number, string, boolean, null, object, array) into an HTML fragment.
  valueToHTML: (value, level = 0) ->
    valueType = Object.prototype.toString.call(value).match(/\s(.+)]/)[1].toLowerCase()
    @["#{valueType}ToHTML"].call(this, value, level)

  nullToHTML: (value) ->
    @decorateWithSpan('null', 'null')

  numberToHTML: (value) ->
    @decorateWithSpan(value, 'num')

  stringToHTML: (value) ->
    if (/^(http|https|file):\/\/[^\s]+$/i.test(value))
      """
      <a href="#{@htmlEncode(value)}"><span class="q">"</span>#{@jsString(value)}<span class="q">"</span></a>
      """
    else
      """
      <span class="string">"#{@jsString(value)}"</span>
      """

  booleanToHTML: (value) ->
    @decorateWithSpan(value, 'bool')

  # Convert an array into an HTML fragment
  arrayToHTML: (array, level = 0) ->
    hasContents = false
    output = ''
    numProps = array.length
    for value, index in array
      hasContents = true
      output += '<li>' + @valueToHTML(value, level + 1)
      output += ',' if  numProps > 1
      output += '</li>'
      numProps--

    if ( hasContents )
      collapsible = if level == 0 then '' else ' collapsible'
      """
        <span class="collapser"></span>[<ul class="array level#{level}#{collapsible}">#{output}</ul>]
      """
    else
      '[ ]'

  # Convert a JSON object to an HTML fragment
  objectToHTML: (object, level = 0) ->
    hasContents = false
    output = ''
    numProps = 0
    for prop of object
      numProps++

    for prop, value of object
      hasContents = true
      output += """
      <li><span class="prop"><span class="q">"</span>#{@jsString(prop)}<span class="q">"</span></span>: #{@valueToHTML(value, level + 1)}
      """
      output += ',' if numProps > 1
      output += '</li>'
      numProps--
    if hasContents
      collapsible = if level == 0 then '' else ' collapsible'
      """
      <span class="collapser"></span>{<ul class="obj level#{level}#{collapsible}">#{output}</ul>}
      """
    else
      '{ }'

  #Convert a whole JSON object into a formatted HTML document.
  jsonToHTML: (json) ->
    """
    <div class="jsonview">#{@valueToHTML(json)}</div>
    """

module? && module.exports = new JSONFormatter
