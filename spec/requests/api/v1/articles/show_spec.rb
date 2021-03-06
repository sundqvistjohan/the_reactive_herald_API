# frozen_string_literal: true

RSpec.describe 'GET /api/v1/articles/:id', type: :request do
  let(:headers) { { HTTP_ACCEPT: 'application/json' } }
  let!(:article) { create(:article, published: true) }
  let!(:subscriber) { create(:subscriber) }
  let(:subscriber_credentials) { subscriber.create_new_auth_token }
  let!(:subscriber_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(subscriber_credentials) }
  let!(:user) { create(:user) }
  let(:user_credentials) { user.create_new_auth_token }
  let!(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }

  describe 'Successfully' do
    describe 'in english' do
      before do
        get "/api/v1/articles/#{article.id}", headers: headers
      end

      it 'returns a 200 response status' do
        expect(response).to have_http_status 200
      end

      it 'returns article title' do
        expect(response_json['article']['title']).to eq 'Breaking News'
      end
    end

    describe 'in swedish' do
      before do
        get "/api/v1/articles/#{article.id}", params: { locale: :sv }, headers: headers
      end

      it 'returns article title in swedish' do
        expect(response_json['article']['title']).to eq 'Brytande nyheter'
      end
    end
  end

  describe 'With invalid :id' do
    describe 'in english' do
      before do
        get '/api/v1/articles/10000', headers: headers
      end

      it 'returns error if article does not exist' do
        expect(response_json['error']).to eq 'Article not found'
      end
    end

    describe 'in swedish' do
      before do
        get '/api/v1/articles/10000',
            params: { locale: :sv },
            headers: headers
      end

      it 'returns error in swedish if article does not exist' do
        expect(response_json['error']).to eq 'Artikeln hittades inte'
      end
    end
  end

  describe 'Successfully' do
    it 'returns shortened article for visitor' do
      get "/api/v1/articles/#{article.id}"
      expect(response_json['article']['body'].length).to eq 350
    end

    it 'returns full length article for subscriber' do
      get "/api/v1/articles/#{article.id}",
          headers: subscriber_headers
      expect(response_json['article']['body'].length).to eq article.body.length
    end
  end

  describe 'With non-published article' do
    before do
      article.update(published: false)
      get "/api/v1/articles/#{article.id}", headers: headers
    end

    it 'returns error if article is not published' do
      expect(response_json['error']).to eq 'Article not found'
    end
  end
end
