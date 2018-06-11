import ConfigParser

def getMasterIp():
    conf = ConfigParser.ConfigParser()
    conf.read('hosts')
    name = conf.get("masters")
    print (name)

if __name__ == "__main__":
    getMasterIp()
    print ('t')
