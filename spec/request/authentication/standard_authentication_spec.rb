# frozen_string_literal: true

require 'rails_helper'

# Note these specs MUST be run in order
RSpec.describe 'authenticating loa1 user', type: :request, order: :defined do
  OUTBOUND_CASSETTE = 'authentication/external_interactions'
  Episode = Struct.new(:method, :uri, :body, :headers, :recorded_at, :response)

  EPISODES = begin
    inbound_cassette_path = 'spec/support/vcr_cassettes/authentication/internal_interactions.yml'
    YAML.safe_load(File.read(inbound_cassette_path))['http_interactions'].map do |interaction|
      req = interaction['request']
      req['uri'] = URI.parse(req['uri'])
      req['recorded_at'] = Time.zone.parse(interaction['recorded_at'].to_s).to_datetime
      req['headers'] = Hash[req['headers'].map { |k, v| [k, v.first] }]
      Episode.new(*req.values, interaction['response'])
    end
  end

  it 'does the tests', :aggregate_failures, :skip_mvi, :skip_emis do
    EPISODES.each_with_index do |episode, _index|
      @episode_time = episode.recorded_at
      Timecop.freeze(@episode_time ) do
        VCR.use_cassette(OUTBOUND_CASSETTE, record: :new_episodes) do
          SecureRandom.with_disabled_randomness do
            make_request(episode)
          end
        end

      actual_body = sanitize_json_body(response.body)
      expected_body = sanitize_json_body(episode.response['body']['string'])
      expect(response.status).to eq(episode.response['status']['code'])
      expect(actual_body).to eq(expected_body)
      expect(response.headers.keys).to eq(episode.response['headers'].keys)
    end
    end
  end

  private

  def sanitize_json_body(body)
    if response.status == 200 && response.content_type.symbol == :json
      body = JSON.parse(body)
      #timecop messes with last_signed_in, so we're changing it to nil for a quick comparison.
      body["data"]["attributes"]["profile"]["lastSignedIn"] = nil if   body["data"].present? && body.dig("data", "attributes", "profile", "lastSignedIn")
      body["data"]["attributes"]["profile"]["last_signed_in"] = nil if   body["data"].present? && body.dig("data", "attributes", "profile", "last_signed_in")
    end
    body
  end

  def make_request(episode)
    params = if episode.method == 'post'
               Rack::Utils.parse_nested_query(episode.body['string'])
             else
               Rack::Utils.parse_nested_query(episode.uri.query)
             end
    send(episode.method, episode.uri.path, params, episode.headers)
  end
end
