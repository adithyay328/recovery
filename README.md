Initially, this was a lot more complex, but now it's actually easy. We use yubikey 5 NFC USB A's for our keys, and we have keys with the following naming scheme:
- a1-a\infty are active keys, i.e. on our person / with us
- b2-b\infty are offsite.

For each, we use age-plugin-yubikey, which underneath the hood uses PIV. You have to install that yourself.

The backup email is adikernel328@gmail.com. The drive attached has a lot of stuff onboard, and then my main gmail has our actual data, all authoritative stuff.

That thing has all our hardware keys installed already, and can be revoked from 2FA.

For passwords, we age encrypt 1 password for each hardware key in this repo. `encrypt.sh` encrypts a password to every recipient in `recipients.txt`, and `decrypt.sh` decrypts it back with your hardware key. Creating a new slot key / overwriting one on the yubikey is manual, via `age-plugin-yubikey --generate` ( not reccomended, not a bright idea a lot of the time, try and rely on hardware keys ). Ideally, make new one, then only once cleared ,then change old pass.

In the case of needing to revoke an old key, cycle is:
1. Log into the google, and revoke their 2fa
2. Generate a new google pasword.
3. Remove the old key from the list of recipient files, and recipients.txt
4. Re-encrypt the new password set with the age public key from each key

In the case of needing add a new key, cycle is:
1. Log into google with an existing key
2. Configure the new yubikey with age-plugin-yubikey as a recipient
3. Store its identity file here, and then add it to recipients.txt.
4. Get into google using the old key, and add the new key as an approved 2FA device
5. Verify that both old and new work. KEEP THE PASSWORD AVAILABLE during the switchover period, just in case. Though, a nice detail with being git comitted is that you can always rollback the ciphertext and get old ones.


# Scripts

## Requirements
- age, plugin-capable (tested with 1.3.2, ~/go/bin/age)
- age-plugin-yubikey (tested with 0.5.1, ~/.cargo/bin)
- pcscd running on Linux: sudo systemctl start pcscd (decrypt.sh checks this for you)

## encrypt.sh
Encrypts a single secret line to every recipient in recipients.txt, writing enc.out.age.

    printf 'y\n<password>\n' | ./encrypt.sh

- First stdin line is the answer to "Have you audited recipients.txt? (y/n)". Anything other than y aborts, no file written.
- The line after the y is the secret; encrypted with age -R recipients.txt, no trailing newline.
- Auditing = recipients.txt contains only non-revoked keys (see revoke cycle above).
- enc.out.age is ciphertext; this repo is public on purpose, so committing it is fine.
- DO NOT use printf actually. Write it in line, makes it safer and avoids console history.

## decrypt.sh
Decrypts a file (defaults to enc.out.age) to stdout, using every *.identity.txt in the repo.

    ./decrypt.sh [file] > out.txt

- age reads the AGE-PLUGIN-YUBIKEY-... line in each identity file (the # comment lines are ignored) and spawns age-plugin-yubikey from PATH.
- The plugin talks to the yubikey whose serial + slot are baked into the identity (a1 = serial 39077936, slot 1), over PC/SC.
- PIN policy Once: prompted once per session. Touch policy Always: touch the key every decrypt, when it blinks.
- If pcscd is down the script exits and tells you the systemctl command.
- Extra identity files are harmless: age tries each against the ciphertext; the plugged key's identity wins.


# Manifest

Below is a manifest of all known keys, and which ones are lost ( NEVER re-use their names ).

## Actives
- a1. Currently active, on me.
- a2. Also active, but a backup 
- b1. Offsite, safe.
