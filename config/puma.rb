# frozen_string_literal: true

if ENV.fetch('APP_ENV', 'development') == 'test'
  port 8000
else
  port 3000
end
