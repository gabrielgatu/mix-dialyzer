[
  apps: [
    remove: [],
    include: []
  ],
  warnings: [
    ignore: [
      {"lib/mod.ex", -1, :no_return},
      {"lib/mod.ex", 6, :*}
    ],
    active: [
      :unmatched_returns,
      :error_handling,
      :unknown
    ]
  ],
  extra_build_dir: []
]
