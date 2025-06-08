# SSL Certificates

## Required Files

Place your SSL certificate files in the following locations:

- `certs/kreacity.cloud.crt` - Your wildcard SSL certificate for *.kreacity.cloud
- `private/kreacity.cloud.key` - Your private key file

## Security Note

These files are excluded from git versioning for security reasons.
Make sure to backup these files separately.

## File Permissions

Recommended permissions:
- Certificate file: 644 (readable by all)
- Private key file: 600 (readable by owner only)

```bash
chmod 644 certs/kreacity.cloud.crt
chmod 600 private/kreacity.cloud.key
```
