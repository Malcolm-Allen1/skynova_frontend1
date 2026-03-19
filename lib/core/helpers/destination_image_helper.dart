String getDestinationImage(String destination) {
  final d = destination.toLowerCase().trim();

  if (d.contains('london')) {
    return 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80';
  }
  if (d.contains('new york') || d.contains('nyc')) {
    return 'https://images.unsplash.com/photo-1499092346589-b9b6be3e94b2?auto=format&fit=crop&w=1200&q=80';
  }
  if (d.contains('toronto')) {
    return 'https://images.unsplash.com/photo-1517935706615-2717063c2225?auto=format&fit=crop&w=1200&q=80';
  }
  if (d.contains('miami')) {
    return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80';
  }
  if (d.contains('paris')) {
    return 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80';
  }

  return 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=1200&q=80';
}

String getRouteImage(String origin, String destination) {
  final route = '${origin.toLowerCase()}-${destination.toLowerCase()}';

  if (route.contains('kingston-london')) {
    return 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80';
  }
  if (route.contains('kingston-new york')) {
    return 'https://images.unsplash.com/photo-1499092346589-b9b6be3e94b2?auto=format&fit=crop&w=1200&q=80';
  }

  return getDestinationImage(destination);
}