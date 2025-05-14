#!/bin/bash

echo "Fixing iOS build issues..."

# Step 1: Remove GeneratedPluginRegistrant.* files
echo "Step 1: Removing generated plugin registrant files"
rm -f ios/Runner/GeneratedPluginRegistrant.*

# Step 2: Install dependencies
echo "Step 2: Running flutter pub get"
flutter pub get

# Step 3: Clean Flutter
echo "Step 3: Running flutter clean"
flutter clean

# Step 4: Pod clean
echo "Step 4: Cleaning iOS Pods"
cd ios
rm -rf Pods
rm -rf .symlinks
rm -f Podfile.lock

# Step 5: Update CocoaPods repos
echo "Step 5: Updating CocoaPods repos"
pod repo update

# Step 6: Pod install with repo update
echo "Step 6: Installing Pods with repo update"
pod install --repo-update
cd ..

echo "Fix completed. Try building your iOS app now."