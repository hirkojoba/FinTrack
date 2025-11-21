# Railway Deployment Guide for FinTrack

This guide will walk you through deploying FinTrack to Railway.app.

## Prerequisites

- A Railway.app account (sign up at https://railway.app/)
- Your GitHub repository with FinTrack code pushed
- An OpenAI API key

## Step 1: Create Railway Account and Connect GitHub

1. Go to https://railway.app/ and click "Login"
2. Choose "Login with GitHub"
3. Authorize Railway to access your GitHub account

## Step 2: Create New Project from GitHub Repository

1. Click "New Project" button on Railway dashboard
2. Select "Deploy from GitHub repo"
3. Find and select your "FinTrack" repository
4. Railway will automatically detect it's a Rails application

## Step 3: Add PostgreSQL Database

1. In your project, click "New" button
2. Select "Database" → "Add PostgreSQL"
3. Railway will automatically provision a PostgreSQL database
4. The DATABASE_URL environment variable will be automatically set

## Step 4: Configure Environment Variables

1. Click on your web service (the FinTrack deployment)
2. Go to the "Variables" tab
3. Click "New Variable" and add the following:

   **Required:**
   - `OPENAI_API_KEY` = your OpenAI API key (starts with sk-...)
   - `RAILS_MASTER_KEY` = (see Step 5 below)

   **Optional (already set automatically):**
   - `DATABASE_URL` - automatically set by Railway PostgreSQL service
   - `PORT` - automatically set by Railway
   - `RAILS_ENV` = production (Railway sets this automatically)

## Step 5: Get Your Rails Master Key

You need to provide the Rails master key to decrypt credentials in production.

Run this command in your local FinTrack directory:

```bash
cat config/master.key
```

Copy the output and add it as the `RAILS_MASTER_KEY` environment variable in Railway.

**Important:** If you don't have a `config/master.key` file, run:

```bash
EDITOR=nano rails credentials:edit
```

This will create the file. Just save and exit (Ctrl+X, then Y, then Enter).

## Step 6: Configure Python Runtime

Railway should automatically detect both Ruby and Python from your project files.

If you encounter Python-related errors:

1. Go to Settings tab in your Railway service
2. Under "Build Command" verify it includes: `pip3 install -r ml_service/requirements.txt`
3. The railway.json file already handles this

## Step 7: Deploy

1. Click "Deploy" or Railway will auto-deploy when you push to GitHub
2. Wait for the build to complete (this may take 3-5 minutes)
3. Watch the deployment logs for any errors

## Step 8: Run Database Migrations

After the first deployment:

1. Go to your service in Railway
2. Click on "Deployments" tab
3. The migrations should run automatically via the Procfile's release command
4. You can verify by checking the deployment logs for "Running migrations"

## Step 9: Access Your Application

1. Go to "Settings" tab in your Railway service
2. Scroll to "Domains" section
3. Click "Generate Domain"
4. Railway will provide a URL like `fintrack-production.up.railway.app`
5. Click the URL to access your deployed application!

## Step 10: Test Your Deployment

1. Sign up for a new account
2. Add some transactions
3. Test the dashboard visualizations
4. Run the forecast feature
5. Test AI insights (this will use your OpenAI API key)
6. Test scenario simulation

## Troubleshooting

### Application won't start

- Check the deployment logs in Railway
- Verify all environment variables are set correctly
- Make sure RAILS_MASTER_KEY is correct

### Database connection errors

- Verify PostgreSQL service is running in Railway
- Check that DATABASE_URL is automatically set
- Ensure migrations ran successfully

### Python ML service errors

- Check that ml_service/requirements.txt exists
- Verify build logs show Python packages being installed
- Make sure forecast.py has correct permissions

### OpenAI API errors

- Verify OPENAI_API_KEY is set correctly in environment variables
- Check your OpenAI account has billing enabled
- Test the key locally first

### Static assets not loading

- Run `rails assets:precompile` is part of Railway's automatic build
- Check that public_file_server.enabled = true in production.rb (already set)

## Updating Your Deployment

Railway automatically redeploys when you push to your GitHub repository:

```bash
git add .
git commit -m "Update feature"
git push origin main
```

Railway will detect the push and automatically redeploy.

## Monitoring

- View real-time logs: Click on your service → "Deployments" → Click on latest deployment
- Check resource usage: Settings → Usage tab
- Monitor database: Click on PostgreSQL service → Metrics

## Cost

Railway offers:
- $5 free trial credits (no credit card required)
- After trial: ~$5-10/month for a hobby project like FinTrack
- PostgreSQL included in base cost

## Security Notes

- Never commit your master.key file to Git (it's already in .gitignore)
- Never commit your .env file to Git (it's already in .gitignore)
- Railway environment variables are encrypted and secure
- Use Railway's environment variables instead of .env in production

## Additional Configuration (Optional)

### Custom Domain

1. Go to Settings → Domains
2. Click "Custom Domain"
3. Follow Railway's instructions to add your domain

### Enable SSL (Already Enabled)

Railway automatically provides SSL certificates for all deployments.

### Set up monitoring alerts

1. Project Settings → Integrations
2. Connect services like Sentry for error tracking

## Support

If you encounter issues:

1. Check Railway documentation: https://docs.railway.app/
2. Railway Discord community: https://discord.gg/railway
3. Check deployment logs for specific error messages
