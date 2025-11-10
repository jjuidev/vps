#!/bin/bash
set -e

echo "🔄 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean -y

echo "✅ System updated successfully!"
