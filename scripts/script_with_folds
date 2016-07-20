#!/bin/bash

travis_fold() {
  local action=$1
  local name=$2
  echo -en "travis_fold:${action}:${name}\r"
}

travis_fold start foo

echo "This line appears in the fold's 'header'"

echo "Stuff inside"

sleep 2

echo "More stuff"

travis_fold end foo
