class MapquestProxyController < ApplicationController

  skip_before_filter :require_auth
  skip_before_filter :require_terms_acceptance
  skip_before_filter :verify_authenticity_token

  def jsproxy

    server_name = params[:sname]
    return render(:nothing => true) unless server_name =~ /\.mapquest\.com$/

    server_port = params[:sport]
    server_path = params[:spath]

    mq_client_id = Config.require(:mapquest_client_id)
    mq_password = Config.require(:mapquest_password)

    server_path = '/'+server_path
    net_http = ProxyUtil.net_http

    if request.post?
      xml = request.raw_post
      server_path << "/mqserver.dll?e=5" if xml.sub!("</Authentication>","<ClientId>#{mq_client_id}</ClientId><Password>#{mq_password}</Password></Authentication>")
      net_http.start(server_name, server_port) { |http|
        http.request_post(server_path, xml) { |response|
          render :xml => response.body
        }
      }
    else

      # efficient hack, mq says server params are always first 3
      post_path << '?' << request['QUERY_STRING'].sub(/(?:.+?\&){3}/,'')

      net_http.start(server_name, server_port) { |http|
        http.request_get(server_path) { |response|
          render :xml => response.body
        }
      }
    end

  end

end