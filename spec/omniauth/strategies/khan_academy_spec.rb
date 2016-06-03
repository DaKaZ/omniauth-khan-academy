require 'spec_helper'

describe OmniAuth::Strategies::KhanAcademy do
  let(:consumer_token){ "dummy_consumer_token" }
  let(:consumer_secret){ "dummy_consumer_secret" }

  let(:khan_academy){ OmniAuth::Strategies::KhanAcademy.new({}, consumer_secret, consumer_token) }
  subject{ khan_academy }


  describe "DEFAULT_CLIENT_OPTIONS" do
    subject{ OmniAuth::Strategies::KhanAcademy::DEFAULT_CLIENT_OPTIONS }

    it{ should eq({"http_method" => :post, "authorize_path" => "/api/auth2/authorize", "site" => "https://www.khanacademy.org", "request_token_path" => "/api/auth2/request_token", "access_token_path" => "/api/auth2/access_token"}) }
  end

  describe "#client_options" do
    context "when the option client_options are not specified" do
      it "should equal the default_client_options" do
        subject.client_options.should eq(OmniAuth::Strategies::KhanAcademy::DEFAULT_CLIENT_OPTIONS)
      end
    end

    context "when the option client_options are specified" do
      let(:custom_client_options){ {"http_method" => :post} }

      subject{ OmniAuth::Strategies::KhanAcademy.new({}, consumer_secret, consumer_token, client_options: custom_client_options) }

      it "should equal the default_client_options merged with the custom options" do
        subject.client_options.should eq(OmniAuth::Strategies::KhanAcademy::DEFAULT_CLIENT_OPTIONS.merge(custom_client_options))
      end
    end
  end

  describe "#request_phase" do
    before do
      khan_academy.stub(:session).and_return({})
    end

    it "should redirect to the authorize url at khan_academy with the request token" do
      pending
      puts "Test the redirect"
    end
  end
end