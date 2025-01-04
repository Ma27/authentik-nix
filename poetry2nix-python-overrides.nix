pkgs:
[
  # modules missing only setuptools
  (final: prev:
    (builtins.listToAttrs (map (name: {
      inherit name;
      value = prev.${name}.overrideAttrs (oA: {
        nativeBuildInputs = (oA.nativeBuildInputs or []) ++ [ final.setuptools ];
      });
    }) [
      "django-cte"
      "django-tenants"
      "dumb-init"
      "drf-orjson-renderer"
    ]))
  )
  (final: prev: {
      xmlsec = prev.xmlsec.overridePythonAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [ final.setuptools final.pkgconfig ];
        buildInputs = [ pkgs.xmlsec.dev pkgs.xmlsec pkgs.libxml2 pkgs.libtool ];
        patches = (oA.patches or []) ++ [
          # From https://github.com/NixOS/nixpkgs/commit/57f6fd617558799b60bc418adec4edd767ac10c2
          (pkgs.fetchpatch {
            url = "https://github.com/xmlsec/python-xmlsec/commit/67cd4ac73e4fceac4b4eb6a320067cad33f79213.patch";
            hash = "sha256-zU34a2x3S48Hwvo/oDe5mfkZ3jBwdajIrKwKhTRSsko=";
          })
        ];
      });
      opencontainers = prev.opencontainers.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.setuptools
          final.pytest
        ];
        postPatch = ''
          substituteInPlace setup.py --replace-fail '"pytest-runner"' '''
        '';
      });
      psycopg-c = prev.psycopg-c.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.setuptools
          final.tomli
          pkgs.postgresql
        ];
      });
      twisted = prev.twisted.overrideAttrs (oA: {
        buildInputs = oA.buildInputs ++ [
          final.hatchling
          final.hatch-fancy-pypi-readme
        ];
      });
      #cryptography = prev.cryptography.overridePythonAttrs (oA: {
      #  cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
      #      src = oA.src;
      #      sourceRoot = "${oA.pname}-${oA.version}/src/rust";
      #      name = "${oA.pname}-${oA.version}";
      #      sha256 = "sha256-PgxPcFocEhnQyrsNtCN8YHiMptBmk1PUhEDQFdUR1nU=";
      #    };
      #});
      dnspython = prev.dnspython.overrideAttrs (oA: {
        buildInputs = oA.buildInputs ++ [
          final.hatchling
        ];
      });
      sqlparse = prev.sqlparse.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.hatchling
        ];
      });
      scim2-filter-parser = prev.scim2-filter-parser.overrideAttrs (oA: {
        patches = [
          (pkgs.fetchpatch {
            name = "replace-poetry-with-poetry-core.patch";
            url = "https://patch-diff.githubusercontent.com/raw/15five/scim2-filter-parser/pull/43.patch";
            hash = "sha256-PjJH1S5CDe/BMI0+mB34KdpNNcHfexBFYBmHolsWH4o=";
          })
        ];
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.poetry-core
        ];
      });
      pendulum = prev.pendulum.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          pkgs.rustPlatform.cargoSetupHook
          pkgs.rustPlatform.maturinBuildHook
        ];
        cargoRoot = "rust";
        cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
          src = oA.src;
          sourceRoot = "${oA.pname}-${oA.version}/rust";
          name = "${oA.pname}-${oA.version}";
          sha256 = "sha256-6fw0KgnPIMfdseWcunsGjvjVB+lJNoG3pLDqkORPJ0I=";
        };
      });
      django-pgactivity = prev.django-pgactivity.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.poetry-core
        ];
      });
      docker = prev.docker.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          prev.hatchling
          prev.hatch-vcs
        ];
      });
      django-pglock= prev.django-pglock.overrideAttrs (oA: {
        nativeBuildInputs = oA.nativeBuildInputs ++ [
          final.poetry-core
        ];
      });
      # https://github.com/pyradius/pyrad/pull/168/files
      # not included in the latest release :/
      pyrad = prev.pyrad.overrideAttrs (oA: {
        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail "poetry.masonry.api" "poetry.core.masonry.api"
        '';
      });
     msgraph-sdk = prev.msgraph-sdk.overrideAttrs (oA: {
       nativeBuildInputs = oA.nativeBuildInputs ++ [
         final.flit-core
       ];
     });
     python-kadmin = prev.python-kadmin.overrideAttrs (oA: {
       nativeBuildInputs = oA.nativeBuildInputs ++ [
         final.setuptools
         final.poetry-core
       ];
       buildInputs = oA.buildInputs ++ [
         pkgs.krb5
       ];
       pythonImportsCheck = [ "kadmin" ];
       NIX_CFLAGS_COMPILE = (oA.NIX_CFLAGS_COMPILE or []) ++ [
         "-Wno-error=int-conversion"
       ];
     });
     gssapi = prev.gssapi.overrideAttrs (oA: {
       nativeBuildInputs = oA.nativeBuildInputs ++ [
         final.setuptools
         final.cython
         pkgs.krb5 # needs krb5-config
       ];
       postPatch = ''
         substituteInPlace setup.py \
           --replace-fail 'get_output(f"{kc} gssapi --prefix")' '"${pkgs.krb5.dev}"'
       '';
       pythonImportsCheck = [ "gssapi" ];
     });
    }
  )
]
