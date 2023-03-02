<div>
  <br>
  <h1>Domain Credential Testing using LDAP</h1>
  <h2> Description </h2>
  <p>The script tries to compare a list of user accounts from a file ("path/users.txt") with default passwords. It attempts to authenticate the user accounts using a fixed password ("StrongP@ssword!") by connecting to a domain controller via the LDAP3 Python module.

The script tries to connect to the domain controller and authenticate the user for each user account. The script prints a message stating that the user has been "Pwn3d" and saves this information in a file called "path/success-login.txt" if the authentication is successful. The script prints a message stating that the login attempt has failed and saves this information in a different file ("path/failed-login.txt") if the authentication fails.

A banner and some notes with instructions are also included in the script for you to get started.</p>
</div>


## ❓ Deppendencies

<br> Python3
<br> ldap3 package



##### Usage
```
pip install -r requirements.txt
```

```
python domain-cred-tester.py
```


## Disclamer

This is developed for red teamers in case it would help you in one of their red team exercises. DO NOT USE IT FOR UNLAWFUL ACTIVITY.
