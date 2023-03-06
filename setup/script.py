import subprocess
import json

aws_account_name = ""
aws_profile_name = ""

mfa = input("Enter your MFA token: ")

s=subprocess.run("aws sts get-session-token --duration-seconds 129600 --serial-number arn:aws:iam::120242891426:mfa/{} --profile {} --token-code %s".format(aws_account_name,aws_profile_name) % mfa, 
shell=True, capture_output=True)
d = s.stdout.decode("utf8")
j = json.loads(d)
s=subprocess.run("aws configure set aws_access_key_id %s --profile session-tna" % j["Credentials"]["AccessKeyId"], shell=True, capture_output=True)
s=subprocess.run("aws configure set aws_secret_access_key %s --profile session-tna" % j["Credentials"]["SecretAccessKey"], shell=True, capture_output=True)
s=subprocess.run("aws configure set aws_session_token %s --profile session-tna" % j["Credentials"]["SessionToken"], shell=True, capture_output=True)
print("MFA session profile, succesfully updated.....")
print("Exporting profile....")
subprocess.run('export AWS_PROFILE=session-tna', shell=True )
print("Done")