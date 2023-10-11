#!/bin/zsh

clang++ main.cpp -o main -std=c++20 -I/Users/nick/VulkanSDK/1.3.261.1/macOS/include -I/opt/homebrew/include -L/Users/nick/VulkanSDK/1.3.261.1/macOS/lib -L/opt/homebrew/lib -lvulkan.1 -lvulkan.1.3.261 -lglfw.3.3 -Wl,-rpath,/Users/nick/VulkanSDK/1.3.261.1/macOS/lib