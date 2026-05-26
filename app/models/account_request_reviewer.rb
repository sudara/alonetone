require "json"
require "net/http"

class AccountRequestReviewer
  ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages".freeze

  Result = Struct.new(:decision, :reason, :alert_status_code, keyword_init: true)

  def initialize(account_request)
    @account_request = account_request
  end

  def review
    return Result.new(decision: "flag", reason: "Auto-review not configured") unless configured?

    response = call_api
    parse_response(response)
  rescue StandardError => e
    Rails.logger.warn("AccountRequestReviewer failed for ##{@account_request.id}: #{e.message}")
    Result.new(
      decision: "flag",
      reason: "Automated review unavailable, needs human review",
      alert_status_code: e.respond_to?(:status_code) ? e.status_code : nil
    )
  end

  private

  def call_api
    uri = URI(ANTHROPIC_API_URL)
    request = Net::HTTP::Post.new(uri)
    request["x-api-key"] = api_key
    request["anthropic-version"] = "2023-06-01"
    request["content-type"] = "application/json"
    request.body = JSON.generate(
      model: model,
      max_tokens: 150,
      system: system_prompt,
      messages: [{ role: "user", content: user_message }]
    )

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30
    http.request(request)
  end

  def parse_response(response)
    if %w[401 429].include?(response.code)
      raise ApiStatusError, response.code
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "Anthropic API returned #{response.code}: #{response.body}"
    end

    body = JSON.parse(response.body)
    text = body.dig("content", 0, "text")
    parsed = JSON.parse(text)

    decision = parsed["decision"]
    reason = parsed["reason"]

    unless %w[approve deny flag].include?(decision)
      raise "Unexpected decision: #{decision}"
    end

    Result.new(decision: decision, reason: reason)
  end

  def user_message
    JSON.generate(
      login: @account_request.login,
      email: @account_request.email,
      entity_type: @account_request.entity_type,
      details: @account_request.details,
      prior_activity_same_ip: ip_summary,
      prior_activity_same_email: email_summary
    )
  end

  def ip_summary
    return "unknown (no IP recorded)" if @account_request.remote_ip.blank?

    status_counts = AccountRequest.where(remote_ip: @account_request.remote_ip)
      .where.not(id: @account_request.id)
      .where.not(status: :waiting)
      .group(:status).count

    summarize_status_counts(status_counts, none: "no prior requests from this IP")
  end

  def email_summary
    status_counts = AccountRequest.where(email: @account_request.email)
      .where.not(id: @account_request.id)
      .where.not(status: :waiting)
      .group(:status).count

    summarize_status_counts(status_counts, none: "no prior requests with this email")
  end

  def summarize_status_counts(status_counts, none:)
    return none if status_counts.empty?

    status_counts.map { |status, count| "#{count} #{status_name(status)}" }.join(", ")
  end

  def status_name(status)
    if status.is_a?(Integer) || status.to_s.match?(/\A\d+\z/)
      AccountRequest.statuses.key(status.to_i) || status.to_s
    else
      status.to_s
    end
  end

  def system_prompt
    Rails.configuration.alonetone.account_review_prompt
  end

  def model
    Rails.configuration.alonetone.account_review_model
  end

  def api_key
    Rails.configuration.alonetone.anthropic_api_key
  end

  def configured?
    api_key.present? && system_prompt.present? && model.present?
  end

  class ApiStatusError < StandardError
    attr_reader :status_code

    def initialize(status_code)
      @status_code = status_code
      super("Anthropic API returned #{status_code}")
    end
  end
end
