import os
import ipaddress
hosts=[]
hosts_up=[]
hosts_down=[]

def check_net(ip):
    try:
        ipaddress.IPv4Network(str(ip))
        return True
    except:ipaddress.AddressValueError
    print('Enter the correct IP address')
    return False

def check_ip(ip):
    try:
        ipaddress.IPv4Address(str(ip))
        return True
    except:ipaddress.AddressValueError
    print('Enter the correct IP address')
    return False

def ping_pref(ip):
    for i in ipaddress.IPv4Network(ip):
        response=os.system('ping -c 1 ' + str(i))
        if response == 0:
            print(f"{i} is up!\n")
            hosts_up.append(i)
        else:
            hosts_down.append(i)
            print(f"{i} is down!\n")
    if hosts_up == []:
        print('LIST OF AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF AVAILABLE HOSTS ===---')
        for i in hosts_up:
            print(f'{i} host available\n')
    if hosts_down == []:
        print('LIST OF NOT AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF NOT AVAILABLE HOSTS ===---')
        for i in hosts_down:
            print(f'{i} host NOT available\n')

def ping_iptoip(ip1:str,ip2:str):
    start_ip=ipaddress.IPv4Address(str(ip1))
    end_ip=ipaddress.IPv4Address(str(ip2))
    for ip in range (int(start_ip),int(end_ip)+1):
        response=os.system('ping -c 1 '+ str(ipaddress.IPv4Address(ip)))
        if response == 0:
            print(f"{ipaddress.IPv4Address(ip)} is up!\n")
            hosts_up.append(ipaddress.IPv4Address(ip))
        else:
            hosts_down.append(ipaddress.IPv4Address(ip))
            print(f"{ipaddress.IPv4Address(ip)} is down!\n")
    if hosts_up == []:
        print('LIST OF AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF AVAILABLE HOSTS ===---')
        for i in hosts_up:
            print(f'{i} host available\n')
    if hosts_down == []:
        print('LIST OF NOT AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF NOT AVAILABLE HOSTS ===---')
        for i in hosts_down:
            print(f'{i} host NOT available\n')

def ping_local_net(hosts):
    for ip in hosts:
        response=os.system('ping -c 1 ' + str(ip))
        if response == 0:
            print(f"{ip} is up!\n")
            hosts_up.append(ip)
        else:
            hosts_down.append(ip)
            print(f"{ip} is down!\n")
    if hosts_up == []:
        print('LIST OF AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF AVAILABLE HOSTS ===---')
        for i in hosts_up:
            print(f'{i} host available\n')
    if hosts_down == []:
        print('LIST OF NOT AVAILABLE HOSTS IS EMPTY\n')
    else:
        print('---=== LIST OF NOT AVAILABLE HOSTS ===---')
        for i in hosts_down:
            print(f'{i} host NOT available\n')

intro=str(input('Choose variant: \n 1. Ping subnet (example: 192.168.1.0/24)\n 2. Ping in range ip1 to ip2\n 3. Ping local network\n > '))
if intro == '1':
    intro1=str(input('Insert subnet '))
    if check_net(intro1) == True:
        ping_pref(intro1)
elif intro == '2':
    start_ip=str(input('Insert first IP '))
    if check_ip(start_ip)==True:
        end_ip=str(input('Insert last IP '))
        if check_ip(end_ip)==True:
            ping_iptoip(start_ip,end_ip)
elif intro == '3':
    ping_local_net(hosts)
    #for i in hosts:
        #check_ip(i)
        #if check_ip(i) == True:
            #ping_local_net(hosts[i])
else:
    print('Choose right variant. Exit... ')