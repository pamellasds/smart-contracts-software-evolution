import subprocess
import glob
import fnmatch
import os
from fuzzywuzzy import fuzz
import re
import itertools 
'''
Função para obter o conteúdo de um arquivo como string
Cada linha do arquivo é lida sequencialmente e anexada a uma única string
Ao final, transforma-se todo o conteúdo para caixa baixa para facilitar a comparação entre strings no futuro
'''
def get_file_as_string(filE):
    etherscan_file = open(filE, "r")

    file_as_string = ""

    for line in etherscan_file:
        # line = line.replace("\n","")
        file_as_string = file_as_string + line

    etherscan_file.close()

    return file_as_string.lower()

'''
Função para obter uma lista sequencial dos commits de um certo repositório
Um arquivo com a lista de commits já deve existir, onde este deve ser extraído utilizando o comando mostrado no arquivo useful_commands.txt
Cada linha do arquivo indica um commit, onde a lista é revertida ao final para podermos processar os commits sequencialmente, do primeiro ao último.
'''
def get_commits(token):
    commits_file = open("github_commits/" + token + "_commits.txt")
    commits = []

    for line in commits_file:
        line = line.replace("\n","")

        commits.append(line)

    commits_file.close()

    commits.reverse()
    return commits


'''
Função para obter uma lista de todos os arquivos solidity num certo diretório
'''
def get_solidity_files_in_folder(token):
    solidity_files_in_folder = []

    for solidity_file in glob.glob("github_repos/" + token + "/" + "**/*.sol", recursive=True):
        solidity_files_in_folder.append(solidity_file)

    
    return solidity_files_in_folder

'''
Função para remover comentários de arquivos solidity
'''
def remove_comments(solidity_code, pattern):
    solidity_code = re.sub(re.compile(pattern ,re.MULTILINE|re.DOTALL ) ,""
    ,solidity_code)

    return solidity_code

'''
Função para remover espaços em branco de arquivos solidity
'''
def remove_blank_spaces(solidity_code, pattern):
    solidity_code = re.sub(re.compile(pattern ,re.MULTILINE|re.DOTALL ) ,""
    ,solidity_code)

    return solidity_code
'''
Função para agrupar arquivos solidity em um mesmo arquivo
'''
def join_solidity_codes(solidity_files):
    
    solidity_code = ""
    for solidity_file in solidity_files:
        solidity_code = solidity_code + get_file_as_string(solidity_file) + "\n"
    
    return solidity_code
'''
Função para realizar combinações de arquivos solidity e comparar com o contrato disponibilizado no Etherscan
'''
def combine_and_compare(token, commit, pattern, patternII, etherscan_code):
    solidity_files_in_folder = []

    for solidity_file in glob.glob("github_contracts_without_comments/" + token + "/" + commit + "/" + "**/*.sol", recursive=True):
        solidity_files_in_folder.append(solidity_file)

    n = len(solidity_files_in_folder)
    count = 1
    while(count <=n):
        result = list(itertools.combinations(solidity_files_in_folder, count))
        filE = open("results_combinations/" + token + "/" + commit + "/" + "combinations_of_" + str(count) + '.csv', "w")
        filE.write("similarity,combination\n")
        for item in result:
            solidity_code = join_solidity_codes(item)
            solidity_code = remove_blank_spaces(solidity_code,patternII)
            
            combination = []
            for line in item:
                combination.append(line.split('/')[-1])

            # mais opções para calcular similaridades em: https://www.datacamp.com/community/tutorials/fuzzy-string-python
            similarity = fuzz.token_sort_ratio(etherscan_code, solidity_code)
            filE.write(str(similarity) + "," + str(combination) + "\n")

        filE.close()
            
        count += 1
    
    return
'''
Função para obter quantidade de arquivos solidity em cada commit
'''
def get_files_amount_per_commit(token, commits):
    
    path = "files_per_commit/"
    try:
        os.mkdir( path + token)
    except OSError:
        print ("Creation of the directory %s failed" % path)

    filE = open("files_per_commit/" + token + "/" + "files_per_commit.csv", "w")
    filE.write("commit,files_amount\n")
    
    for commit in commits:
        solidity_files_in_folder = []
        for solidity_file in glob.glob("github_contracts_without_comments/" + token + "/" + commit + "/" + "**/*.sol", recursive=True):
            solidity_files_in_folder.append(solidity_file)
        filE.write( commit + "," + str(len(solidity_files_in_folder))+ "\n")
    
    filE.close()

    return

############################# SCRIPT IS EXECUTED FROM HERE ##############################


# lista com os nomes de cada tolen/criptomoeda, este nome deve ser reusado em varios outros arquivos e diretorios
tokens = [
"ChainLink-Token",
"HuobiToken",
"VeChain",
"Paxos-Standard",
"TrueUSD",
"Reputation",
"KyberNetwork",
"Dai-Stablecoin",
"Theta-Token",
"Nexo",
"EnjinCoin",
"MCO",
"Binance-USD",
"Bytom",
"DxChain-Token",
"Swipe",
"Zilliqa",
"AION",
"SeeleToken",
"Golem",
"WAX-Token",
"RLC",
"PowerLedger",
"Decentraland",
"Aragon",
"Bancor",
"HEDG",
"EthLend",
"Synthetix Network Token",
"OKB"
]

print("Calculando similaridades...")
pattern = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|\-.*?)|(//.*?[\s\S]$)" #Parâmentro com espaços em branco
patternII = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|\-.*?)|(//.*?[\s\S]$|\s.*?)" #Parâmentro sem espaços em branco

for token in tokens:
    print(token + ": Calculando similaridades" )
    
    # obtém-se o código do token vindo do etherscan numa string e removendo comentários
    etherscan_code = get_file_as_string("etherscan_contracts/" + token + ".sol")
    etherscan_code = remove_comments(etherscan_code,pattern)
    filE = open("etherscan_contracts_without_comments/" + token + ".sol" , "w")
    filE.write(etherscan_code)
    filE.close
    #removendo espaços em branco
    etherscan_code = remove_blank_spaces(etherscan_code,patternII)

    #criando diretório para receber contratos presentes no GITHUB sem comentários para cada token 
    path = "github_contracts_without_comments/"
    try:
        os.mkdir( path + token ) 
    except OSError:
        print ("Creation of the directory %s failed" % path)


    #criando diretório para receber os resultados de combinações de cada contrato
    path = "results_combinations/"
    try:
        os.mkdir( path + token)
    except OSError:
        print ("Creation of the directory %s failed" % path)

    # obtém-se a lista de commits do repositório do token
    commits = get_commits(token)

    #obtendo a quantidade de arquivos .sol por cada commit
     get_files_amount_per_commit(token, commits)

    for commit in commits:
        print("Commit - " + commit)
        #criando diretório para receber contratos de cada commit 
        path = "github_contracts_without_comments/"
        try:
            os.mkdir( path + token + "/" + commit) 
        except OSError:
            # continue
            print ("Creation of the directory %s failed" % path)

        #criando diretório para receber os resultados de combinações para cada commit 
        path = "results_combinations/"
        try:
            os.mkdir( path + token + "/" + commit)
        except OSError:
            if OSError:
                print ("Creation of the directory %s failed" % path)
                continue
    
        # primeiramente, resetar o repositório para o estado do commit
        subprocess.Popen(["git", "-C", "github_repos/" + token + "/" + token, "reset",  "--hard", commit], stdout=subprocess.PIPE).communicate()

        # identifica-se todos os arquivos solidity do projeto
        solidity_files = get_solidity_files_in_folder(token)
        
        # caso não exista arquivos solidity para este commit, escreve-se no resultado que não há arquivos em solidity neste commit
        if len(solidity_files) == 0:
            print('')
            # similarity_results_II.write(commit + ",-1\n")
        else:
            # para cada arquivo solidity no projeto, calcula-se a similaridade com o codigo fonte do etherscan e grava-se no arquivo de resultados
            for solidity_file in solidity_files:
                # removendo comentários de código solidity e gravando em arquivo
                solidity_code = get_file_as_string(solidity_file)
                solidity_code = remove_comments(solidity_code,pattern)
                filE = open("github_contracts_without_comments/" + token + "/" + commit + "/" + solidity_file.split('/')[-1], "w")
                filE.write(solidity_code)
                filE.close()

            #comparando combinações de contratos presentes em cada commit
            combine_and_compare(token, commit , pattern, patternII , etherscan_code)

    print(token + ":Calculo de similaridade concluído")

