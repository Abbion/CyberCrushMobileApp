extends Node

func fuzzy_string(str_1: String, str_2: String) -> float:
	if str_1.is_empty() and str_2.is_empty():
		return 1.0
	if str_1.is_empty() or str_2.is_empty():
		return 0.0

	var len_1 := str_1.length()
	var len_2 := str_2.length()

	var dist := []
	for i in range(len_1 + 1):
		dist.append([])
		for j in range(len_2 + 1):
			if j == 0:
				dist[i].append(i)
			elif i == 0:
				dist[i].append(j)
			else:
				dist[i].append(0)

	# Fill matrix
	for i in range(1, len_1 + 1):
		for j in range(1, len_2 + 1):
			var cost = 0 if str_1[i - 1] == str_2[j - 1] else 1

			dist[i][j] = min(
				dist[i - 1][j] + 1,        # deletion
				dist[i][j - 1] + 1,        # insertion
				dist[i - 1][j - 1] + cost  # substitution
			)

	var distance := float(dist[len_1][len_2])
	var max_len := float(max(len_1, len_2))

	return 1.0 - (distance / max_len)
