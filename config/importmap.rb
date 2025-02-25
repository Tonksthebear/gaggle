pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin_all_from File.expand_path("../app/javascript/gaggle", __dir__), under: "gaggle"
pin_all_from File.expand_path("../app/javascript/controllers/", __dir__), under: "controllers"
