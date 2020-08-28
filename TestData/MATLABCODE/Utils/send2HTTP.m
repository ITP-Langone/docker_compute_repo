function[RE]=send2HTTP(url)
import matlab.net.*
import matlab.net.http.*
r = RequestMessage;
RE = send(r,url);
end

