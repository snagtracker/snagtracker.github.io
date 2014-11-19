---
---

# register file drop handler
$ ->
  return if typeof window.FileReader == 'undefined'

  holder = $('body')
  holder.on 'dragover', (e) ->
    holder.addClass 'hover'
    e.preventDefault()
    e.stopPropagation()
  holder.on 'dragend', ->
    holder.removeClass 'hover'
    e.preventDefault()
    e.stopPropagation()
  holder.on 'drop', (e) ->
    holder.removeClass 'hover'
    e.preventDefault()
    e.stopPropagation()
    return unless file = e.originalEvent?.dataTransfer?.files[0]
    return alert 'Cancelling upload, file is not a PDF document' unless file.type == 'application/pdf'
    $('#file-upload-progress').modal 'show'
    reader = new FileReader()
    reader.onload = (event) ->
      $.ajax
        type: "POST"
        data:
          dataURL:     event.target.result
          name:        file.name
          contentType: file.type
          size:        file.size
        dataType: 'json'
        url: "http://service.snagtracker.com:8080/tiler"
        success: (response, textStatus, jqXHR) ->
          # console.log 'SUCCESS', arguments
          if response.ok
            parts = response.server.split('.')
            parts[0] = response.db
            window.location.href = "https://"+parts.join('.')
        error: ->
          # console.log 'ERROR', arguments
        xhr: ->
          xhr = new window.XMLHttpRequest()
          progressElement = $ '#file-upload-progress .progress-bar'
          xhr.upload.addEventListener "progress", (evt) ->
            progressElement.css 'width', (100 * evt.loaded / evt.total) + '%' if evt.lengthComputable
          , false
          # xhr.addEventListener "progress", (evt) ->
          #   console.log 'down', evt.loaded / evt.total if evt.lengthComputable
          # , false
          xhr
    reader.readAsDataURL file
