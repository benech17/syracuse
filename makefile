all:
	gcc -Wall syracuse.c -o syracuse
	@echo "Production de syracuse effectuée."
    
clean: 
	@echo "Nettoyage de syracuse"
	@rm -rf syracuse

mrProper: 
	@echo "Nettoyage de tous les fichiers dat"
	@rm -rf f*.dat