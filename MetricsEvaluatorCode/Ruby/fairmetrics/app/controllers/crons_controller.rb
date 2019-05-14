class CronsController < ApplicationController
  def clearcache
    if request.headers["X-Appengine-Cron"]
      Dir.glob("/tmp/*").select{ |file| /_head/.match file }.each { |file| File.delete(file)}
      Dir.glob("/tmp/*").select{ |file| /_body/.match file }.each { |file| File.delete(file)}
      Dir.glob("/tmp/*").select{ |file| /_uri/.match file }.each { |file| File.delete(file)}

      head :ok
    else
      head :not_found
    end
  end
end