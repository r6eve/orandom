DUNE = dune

all:
	$(DUNE) build

test:
	$(DUNE) runtest

clean:
	$(DUNE) clean
