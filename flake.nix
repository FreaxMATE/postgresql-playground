{
  description = "PostgreSQL Learning Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        postgresql = pkgs.postgresql_15;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ postgresql ];
          
          shellHook = ''
            # Set up local PostgreSQL
            export PGDATA="$PWD/.pgdata"
            export PGHOST="$PWD/.pgdata"
            
            echo "PostgreSQL Learning Environment"
            echo "==============================="
            echo ""
            
            # Initialize database if needed
            if [ ! -d "$PGDATA" ]; then
              echo "Initializing PostgreSQL database..."
              initdb --no-locale --encoding=UTF8
              
              # Configure for Unix socket only (no port conflicts)
              cat >> "$PGDATA/postgresql.conf" <<EOF
unix_socket_directories = '$PGDATA'
listen_addresses = '''
EOF
              
              echo "Starting PostgreSQL..."
              pg_ctl -l "$PGDATA/postgres.log" start
              sleep 2
              
              echo "Creating 'mylearning' database..."
              createdb mylearning
              
              echo ""
              echo "✓ PostgreSQL ready!"
            else
              # Check if already running
              if ! pg_ctl status > /dev/null 2>&1; then
                echo "Starting PostgreSQL..."
                pg_ctl -l "$PGDATA/postgres.log" start
                sleep 1
              fi
              echo "✓ PostgreSQL is running"
            fi
            
            echo ""
            echo "Quick commands:"
            echo "  psql mylearning     - Connect to database"
            echo "  psql -f <file>      - Run SQL file"
            echo "  pg_ctl stop         - Stop PostgreSQL"
            echo ""
          '';
        };
      }
    );
}
