#!/bin/sh

sed -i "s@set \$upstream_mirror_host        '';@set \$upstream_mirror_host        '';\n            set \$upstream_mirror_uri         '';@" /usr/bin/apisix \
&& sed -i "s@proxy_pass \$upstream_mirror_host\$request_uri;@if (\$upstream_mirror_uri = \"\"){\n                set \$upstream_mirror_uri \$request_uri;\n            }\n\n            proxy_pass \$upstream_mirror_host\$upstream_mirror_uri;@" /usr/bin/apisix \
&& sed -i "s@env APISIX_PROFILE;@env APISIX_PROFILE;\nenv TNS_ADMIN;\nenv DATACENTER_ID=1;@" /usr/bin/apisix \
&& sed -i "s@upstream_mirror_host       = true,@upstream_mirror_host       = true,\n        upstream_mirror_uri       = true,@" /usr/local/apisix/apisix/core/ctx.lua
