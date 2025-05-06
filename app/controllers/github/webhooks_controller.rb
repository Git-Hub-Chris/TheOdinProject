class Github::WebhooksController < ApplicationController
  include GithubWebhook::Processor

  def github_push(payload)
    unless valid_signature?(request)
      head :unauthorized
      return
    end

    event = ::Github::PushEvent.new(payload)

    Lessons::UpdateContentJob.perform_later(event.modified_urls) if event.merged_to_main?
  end

  private

  def webhook_secret(_)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
  def valid_signature?(request)
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      webhook_secret(nil),
      request.body.read
    )
    Rack::Utils.secure_compare(signature, request.headers['X-Hub-Signature-256'].to_s)
  end
end
