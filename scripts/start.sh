#!/bin/bash

export MIX_ENV=prod

mix compile
elixir --no-halt -S mix
