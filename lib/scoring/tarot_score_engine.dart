enum Contrat { prise, garde, gardeSans, gardeContre }

extension ContratCoefficient on Contrat {
  int get coefficient {
    switch (this) {
      case Contrat.prise:
        return 1;
      case Contrat.garde:
        return 2;
      case Contrat.gardeSans:
        return 4;
      case Contrat.gardeContre:
        return 6;
    }
  }
}

enum PetitAuBout { aucun, preneur, defense }

enum Poignee { aucune, simple, double, triple }

extension PoigneePrime on Poignee {
  int get prime {
    switch (this) {
      case Poignee.aucune:
        return 0;
      case Poignee.simple:
        return 20;
      case Poignee.double:
        return 30;
      case Poignee.triple:
        return 40;
    }
  }
}

enum ChelemType {
  aucun,
  preneurAnonceReussi,
  preneurNonAnonceReussi,
  preneurAnonceRate,
  defenseInflige,
}

/// Seuil de points que le preneur doit atteindre selon le nombre de bouts
/// détenus dans ses levées (règlement FFT, version du 1er juillet 2012).
int seuilPreneur(int bouts) {
  switch (bouts) {
    case 0:
      return 56;
    case 1:
      return 51;
    case 2:
      return 41;
    case 3:
      return 36;
    default:
      throw ArgumentError('bouts doit être compris entre 0 et 3, reçu: $bouts');
  }
}

class ManchInput {
  final int nombreJoueurs;
  final Contrat contrat;
  final int pointsPreneur;
  final int bouts;
  final PetitAuBout petitAuBout;
  final Poignee poignee;
  final ChelemType chelem;
  final List<int> joueurIds;
  final int preneurId;
  final int? appeleId;

  const ManchInput({
    required this.nombreJoueurs,
    required this.contrat,
    required this.pointsPreneur,
    required this.bouts,
    this.petitAuBout = PetitAuBout.aucun,
    this.poignee = Poignee.aucune,
    this.chelem = ChelemType.aucun,
    required this.joueurIds,
    required this.preneurId,
    this.appeleId,
  });
}

class ManchResult {
  final Map<int, int> deltasParJoueur;
  final int montant;
  final bool preneurGagne;

  const ManchResult({
    required this.deltasParJoueur,
    required this.montant,
    required this.preneurGagne,
  });
}

/// Calcule la répartition des points d'une manche entre tous les joueurs
/// d'une partie, en appliquant exactement le barème officiel FFT.
///
/// Le "montant" est la valeur signée (positive si le preneur gagne, négative
/// sinon) après application du petit au bout, de la poignée et du chelem
/// poolé du preneur — avant multiplication par le coefficient de
/// distribution (3 à 4 joueurs, 2 à 3 joueurs, 2/1 ou 4 à 5 joueurs).
ManchResult calculerManche(ManchInput input) {
  if (input.nombreJoueurs != 3 && input.nombreJoueurs != 4 && input.nombreJoueurs != 5) {
    throw ArgumentError('nombreJoueurs doit être 3, 4 ou 5, reçu: ${input.nombreJoueurs}');
  }
  if (input.pointsPreneur < 0 || input.pointsPreneur > 91) {
    throw ArgumentError('pointsPreneur doit être entre 0 et 91, reçu: ${input.pointsPreneur}');
  }
  if (input.nombreJoueurs == 5 && input.appeleId == null) {
    throw ArgumentError('appeleId est requis à 5 joueurs');
  }

  final seuil = seuilPreneur(input.bouts);
  final ecart = (input.pointsPreneur - seuil).abs();
  final preneurGagne = input.pointsPreneur >= seuil;
  final signe = preneurGagne ? 1 : -1;
  final coefficient = input.contrat.coefficient;

  var net = signe * (25 + ecart) * coefficient;

  if (input.petitAuBout == PetitAuBout.preneur) {
    net += 10 * coefficient;
  } else if (input.petitAuBout == PetitAuBout.defense) {
    net -= 10 * coefficient;
  }

  if (input.poignee != Poignee.aucune) {
    net += signe * input.poignee.prime;
  }

  switch (input.chelem) {
    case ChelemType.preneurAnonceReussi:
      net += 400;
      break;
    case ChelemType.preneurNonAnonceReussi:
      net += 200;
      break;
    case ChelemType.preneurAnonceRate:
      net -= 200;
      break;
    case ChelemType.aucun:
    case ChelemType.defenseInflige:
      break;
  }

  final montant = net;
  final estSeul = input.nombreJoueurs == 5 && input.appeleId == input.preneurId;
  final deltas = <int, int>{};

  if (input.nombreJoueurs == 4) {
    deltas[input.preneurId] = montant * 3;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else if (input.nombreJoueurs == 3) {
    deltas[input.preneurId] = montant * 2;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else if (estSeul) {
    deltas[input.preneurId] = montant * 4;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else {
    deltas[input.preneurId] = montant * 2;
    deltas[input.appeleId!] = montant;
    for (final id in input.joueurIds) {
      if (id != input.preneurId && id != input.appeleId) deltas[id] = -montant;
    }
  }

  if (input.chelem == ChelemType.defenseInflige) {
    for (final id in input.joueurIds) {
      final estAttaque = id == input.preneurId || (!estSeul && id == input.appeleId);
      if (!estAttaque) {
        deltas[id] = (deltas[id] ?? 0) + 200;
      }
    }
  }

  return ManchResult(deltasParJoueur: deltas, montant: montant, preneurGagne: preneurGagne);
}
