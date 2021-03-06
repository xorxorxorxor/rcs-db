#
# Controller for the Signature objects
#

module RCS
module DB

class SignatureController < RESTController

  # retrieve the signature for a given entity
  # e.g. 'agent', 'network', ...
  def show
    require_auth_level :server, :admin, :sys
    
    begin
      if @params['_id'] == 'server.pem'
        sig = {}
        sig[:filename] = Config.instance.global['CA_PEM']
        sig[:value] = File.open(Config.instance.cert('CA_PEM'), 'rb') {|f| f.read}
        trace :info, "[#{@request[:peer]}] Requested the CA certificate"
      elsif @params['_id'] == 'network.pem'
        sig = {}
        sig[:filename] = 'rcs-network.pem'
        sig[:value] = File.open(Config.instance.cert('rcs-network.pem'), 'rb') {|f| f.read}
        trace :info, "[#{@request[:peer]}] Requested the network certificate"
      elsif @params['_id'] == 'check'
        sig = {}
        sig[:value] = LicenseManager.instance.limits[:magic]
      else
        sig = ::Signature.where({scope: @params['_id']}).first
        trace :info, "[#{@request[:peer]}] Requested the '#{@params['_id']}' signature [#{sig[:value]}]"
      end
      return ok(sig)
    rescue Exception => e
      trace :warn, "[#{@request[:peer]}] Requested '#{@params['_id']}' NOT FOUND"
      return not_found
    end
  end

end

end #DB::
end #RCS::
