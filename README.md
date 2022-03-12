1 - A sequência correta para execução da pesquisa é:
    <ol>
    1° get_repositories_and_commits.py<br>
    2° compute_similarities.py<br>
    3° find_greater_similarity.py<br>
    4° get_repositories_insights.py<br>
    </ol>

2 - A pastas "etherscan_contracts", "etherscan_contracts_without_comments", "files_per_commit", "github_commits", "github_contracts_without_comments" armazenarão os dados que serão utilizados nas análises.

3 - A pasta "results_combinations" conterá, para commit de cada projeto, arquivos .csv contendo como dados a lista dos arquivos usados nas combinações realizadas e suas respectivas similaridades.

4 - A pasta "repositories_insights" conterá a evolução de similaridade de cada projeto. Dentro de cada pasta existe um arquivo .csv com os dados seguintes dados:
    <ol>
    * Hash do commit<br>
    * Grau de similaridade da combinação/combinação utilizada para gerar similaridade.<br>
    </ol>

5 - A pasta "repositories_insights" apresentará os dados finais gerados para a pesquisa.
