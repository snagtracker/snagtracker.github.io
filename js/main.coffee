---
---

isDevelopment = window.location.hostname == 'localhost'
account = (->
    parts = window.location.hostname.split('.')
    return 'free' if parts.length != 3 || parts[1] != 'snagtracker'
    parts[0]
  )()

# register file drop handler
$ ->
  return if typeof window.FileReader == 'undefined'

  eventCount = 0

  $('body').on
    dragover: (e) ->
      e.preventDefault()
      e.stopPropagation()
    dragenter: (e) ->
      $('#file-upload-progress').modal 'show' if eventCount++ == 0
      e.preventDefault()
      e.stopPropagation()
    dragleave: (e) ->
      $('#file-upload-progress').modal 'hide' if --eventCount == 0
      e.preventDefault()
      e.stopPropagation()
    drop: (e) ->
      $('#file-upload-progress').modal 'hide'
      eventCount = 0
      e.preventDefault()
      e.stopPropagation()

  $('#file-upload-progress .modal-dialog').on
    drop: (e) ->
      return unless file = e.originalEvent?.dataTransfer?.files[0]
      unless file.name.match(/.pdf$/i) || file.type == 'application/pdf'
        return alert 'Cancelling upload, file is not a PDF document'

      e.preventDefault()
      e.stopPropagation()

      reader = new FileReader()
      reader.onload = (event) ->
        $.ajax
          type: "POST"
          data:
            dataURL:     event.target.result
            name:        file.name
            contentType: 'application/pdf'
            size:        file.size
          dataType: 'json'
          url: if isDevelopment then 'http://localhost:8080/tiler/mzoiyg/2' else "/service/tiler/#{account}"
          success: (response, textStatus, jqXHR) ->
            if response.ok
              if isDevelopment
                console.log response
              else
                parts = response.server.split('.')
                parts[0] = response.db
                window.location.href = "https://"+parts.join('.')
          error: ->
            if isDevelopment
              console.log 'ERROR', arguments
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
    dragover: (e) ->
      e.originalEvent.dataTransfer.dropEffect = 'copy'
