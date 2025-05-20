# typed: false

class DummyHeadController < Kirei::Controller
  def index
    render('ok', status: 200)
  end
end

RSpec.describe 'HEAD request handling' do
  before do
    Kirei::Routing::Router.instance.routes.clear
    route = Kirei::Routing::Route.new(
      verb: Kirei::Routing::Verb::GET,
      path: '/head',
      controller: DummyHeadController,
      action: 'index'
    )
    Kirei::Routing::Router.add_routes([route])
  end

  it 'returns empty body for HEAD requests' do
    env = {
      'REQUEST_METHOD' => 'HEAD',
      'REQUEST_PATH' => '/head',
      'QUERY_STRING' => '',
      'rack.input' => StringIO.new(''),
      'HTTP_HOST' => 'example.com',
      'REMOTE_ADDR' => '127.0.0.1'
    }

    status, _headers, body = Kirei::Routing::Base.new.call(env)

    expect(status).to eq(200)
    expect(body).to eq([])
  end
end
