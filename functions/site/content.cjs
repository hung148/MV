'use strict';

// Website copy migrated from lib/screens. Keep content independent of rendering.
const services = [
  ['CNC Milling', 'Precision milling services for complex parts', ['3-axis capabilities', 'Tolerances to ±0.0005"', 'Prototype to production', 'Personal attention on every job']],
  ['Rapid Prototyping', 'Fast turnaround for prototype development', ['Quick quote within 24 hours', 'Single or low-volume runs', 'Design consultation available', 'Material recommendations']],
  ['Production Manufacturing', 'Consistent quality on every production run', ['Low to medium volume capabilities', 'Quality control at every step', 'Just-in-time delivery options', 'Owner-operated precision']],
  ['Swiss Machining', 'Ultra-precise parts for demanding applications', ['Complex geometries', 'Tight tolerances', 'Small diameter work', 'High-volume capability']],
  ['Assembly Services', 'Complete assembly and sub-assembly solutions', ['Mechanical assembly', 'Testing and validation', 'Packaging solutions', 'Quality documentation']],
];
const values = [
  ['Quality First', 'We never compromise on quality. Every part is inspected to ensure it meets or exceeds specifications.'],
  ['Integrity', 'Honest communication, fair pricing, and transparent processes build trust with our clients.'],
  ['Innovation', 'Continuous investment in technology and training keeps us at the forefront of the industry.'],
  ['Teamwork', 'Our skilled team works collaboratively to solve challenges and deliver exceptional results.'],
  ['Customer Focus', 'Understanding and exceeding customer expectations drives everything we do.'],
  ['Continuous Improvement', 'We constantly improve our equipment, processes, and skills to better serve our customers.'],
];
const materials = [
  ['Metals', '', ['Aluminum (all alloys)', 'Stainless Steel (300/400 series)', 'Steel (mild, tool, alloy)', 'Brass & Bronze', 'Copper', 'Inconel & Hastelloy']],
  ['Plastics', '', ['PEEK', 'Delrin (Acetal)', 'Nylon', 'PTFE (Teflon)', 'Polycarbonate', 'UHMW', 'Ultem']],
  ['Specialty Materials', '', ['Carbon Fiber', 'G10/FR4', 'Ceramics', 'Graphite', 'Exotic alloys', 'Medical-grade materials']],
];
const equipment = [
  ['CMM Inspection', '', ['Measuring volume: 24" x 24" x 16"', 'Accuracy: 0.0001"', 'Contact and optical probing', 'Full dimensional reports']],
  ['Surface Grinding', '', ['Capacity: 24" x 12" x 12"', 'Tolerance: ±0.0002"', 'Surface finish: Ra 4', 'Magnetic and vacuum chucks']],
];
const tolerances = [
  ['±0.0005"', 'Linear Tolerances', 'Standard tight tolerance capability'],
  ['±0.25°', 'Angular Tolerances', 'Precise angular measurements'],
  ['Ra 4–8 µin', 'Surface Finish', 'Excellent surface quality'],
  ['0.0002"', 'Roundness', 'Exceptional circularity'],
];
const capacity = [['Prototype', 'to Production'], ['1,000+', 'Parts/Month'], ['24hr', 'Quote Turnaround'], ['2', 'CNC Machines']];
const gallery = Array.from({ length: 43 }, (_, i) => `/assets/images/gallery/gallery_${i + 1}.webp`);
const routes = {
  '/': { label: 'Home', eyebrow: 'MV Manufacturing LLC · Santa Clara, CA', title: 'Precision CNC Manufacturing', subtitle: 'Your trusted partner for high-quality machining solutions', video: 'home_hero_bg.mp4', seo: 'CNC Precision Machining in Santa Clara, CA | MV Manufacturing LLC', description: 'Owner-operated CNC milling and precision machining in Santa Clara, CA. Fast 24-hour quotes, tolerances to ±0.0005", aerospace and medical parts welcome.' },
  '/services': { label: 'Services', title: 'Our Services', subtitle: 'Comprehensive CNC machining solutions for all your manufacturing needs', video: 'services_hero_bg.mp4', seo: 'CNC Machining Services — Milling, Prototyping & Production | MV Manufacturing LLC', description: 'CNC milling, rapid prototyping, and production runs for aerospace, medical, and industrial clients. Personal attention on every job by owner Minh Vu.' },
  '/capabilities': { label: 'Capabilities', title: 'Our Capabilities', subtitle: 'State-of-the-art equipment and expertise to handle your most demanding projects', video: 'capabilities_hero_bg.mp4', seo: 'CNC Capabilities — Tolerances, Materials & Equipment | MV Manufacturing LLC', description: 'Precision CNC capabilities: tolerances to ±0.0005", aluminum, stainless steel, brass, copper, and plastics. Located in Santa Clara, CA.' },
  '/about': { label: 'About Us', title: 'About MV Manufacturing LLC', subtitle: 'Family-owned craftsmanship, dependable quality, and personalized CNC machining services.', seo: 'About MV Manufacturing LLC — Owner-Operated CNC Shop in Santa Clara', description: 'Founded in 2025 by master machinist Minh Vu. Every part personally inspected. Serving aerospace, medical, and industrial clients from Santa Clara, CA.' },
  '/gallery': { label: 'Gallery', title: 'Our Work', subtitle: 'Precision machined components across industries', seo: 'Machined Parts Gallery | MV Manufacturing LLC', description: 'Photos of precision CNC machined components produced at MV Manufacturing LLC — aluminum and stainless steel parts for aerospace, medical, and industrial use.' },
};
module.exports = { services, values, materials, equipment, tolerances, capacity, gallery, routes };
