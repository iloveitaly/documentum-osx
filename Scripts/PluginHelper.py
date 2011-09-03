import user, sys, os

APP_NAME = 'PyHelp'
APP_SUPPORT_DIR = user.home + '/Library/Application Support/' + APP_NAME + '/'
PLUGIN_SUPPORT_DIR = ''

# This Will Attempt to Generalize some common python operations

def init(pluginName):
	# init the application paths
	global PLUGIN_SUPPORT_DIR
	
	PLUGIN_SUPPORT_DIR = APP_SUPPORT_DIR + pluginName

	if len(sys.argv) > 1:
		sys.path.append(sys.argv[1])
	else:
		sys.path.append(APP_SUPPORT_DIR + "pymodules")
		os.chdir(PLUGIN_SUPPORT_DIR)
	
	return PLUGIN_SUPPORT_DIR
	