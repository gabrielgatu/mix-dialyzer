[
  apps: [
    remove: [],
    include: []
  ],
  warnings: [
    ignore: [
      {"lib/mod.ex", 5, :no_return}
    ],
    active: [
      :unmatched_returns,
      :error_handling,
      :unknown
    ]
  ],
  extra_build_dir: []
]
