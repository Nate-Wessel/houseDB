--
-- PostgreSQL database dump
--

\restrict mTnNEUFR5XRXaE4NGSdOLw6WwIKz4jNVR8eXffFLvqobqZx8ei5fUQ2CDtIBAgK

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: circuits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circuits (
    uid text NOT NULL,
    panel text NOT NULL,
    amps smallint NOT NULL,
    gfci boolean,
    afci boolean,
    voltage smallint,
    CONSTRAINT circuits_amps_check CHECK ((amps > 0))
);


--
-- Name: floors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.floors (
    uid text NOT NULL
);


--
-- Name: interface_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interface_types (
    short_name text NOT NULL
);


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interfaces (
    space text NOT NULL,
    location_in_space text NOT NULL,
    circuit text,
    interface_type text NOT NULL,
    grounded boolean,
    notes text,
    rewired boolean,
    uid smallint NOT NULL
);


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    short_name text NOT NULL,
    floor text NOT NULL,
    description text
);


--
-- Name: interfaces_by_circuit; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.interfaces_by_circuit AS
 SELECT circuits.uid AS circuit,
    circuits.amps,
    COALESCE(bool_or(interfaces.rewired), false) AS has_rewired_interfaces,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) AS interface_count,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) FILTER (WHERE (NOT interfaces.grounded)) AS ungrounded_interfaces,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) FILTER (WHERE (interfaces.grounded IS NULL)) AS interfaces_grounding_unknown,
    array_agg(DISTINCT interfaces.space ORDER BY interfaces.space) FILTER (WHERE (interfaces.space IS NOT NULL)) AS spaces,
    array_agg(DISTINCT spaces.floor ORDER BY spaces.floor) AS floors
   FROM ((public.circuits
     LEFT JOIN public.interfaces ON ((interfaces.circuit = circuits.uid)))
     LEFT JOIN public.spaces ON ((interfaces.space = spaces.short_name)))
  GROUP BY circuits.uid, circuits.amps
  ORDER BY (count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type))) DESC;


--
-- Name: interfaces_uid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interfaces_uid_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interfaces_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interfaces_uid_seq OWNED BY public.interfaces.uid;


--
-- Name: panels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.panels (
    short_name text NOT NULL,
    description text,
    notes text,
    circuit text
);


--
-- Name: wires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wires (
    connects_from smallint NOT NULL,
    connects_to smallint NOT NULL,
    gauge smallint,
    ground boolean DEFAULT true,
    notes text,
    conductors smallint DEFAULT 2 NOT NULL,
    CONSTRAINT wires_check CHECK ((connects_from <> connects_to))
);


--
-- Name: interfaces uid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces ALTER COLUMN uid SET DEFAULT nextval('public.interfaces_uid_seq'::regclass);


--
-- Data for Name: circuits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.circuits (uid, panel, amps, gfci, afci, voltage) FROM stdin;
1	subpanel	15	f	f	120
10	subpanel	15	f	f	120
3	subpanel	15	f	f	120
4	subpanel	15	f	f	120
5	subpanel	15	f	f	120
8	subpanel	15	f	f	120
9	subpanel	15	f	f	120
A25B	main	15	f	f	120
B20A	main	15	f	f	120
B22A	main	15	f	f	120
B4A	main	15	f	f	120
B28A/B30A	main	30	f	f	240
B8A/B10A	main	30	f	f	240
A21B/A23B	main	30	f	f	240
B12A/B14A	main	40	f	f	240
B16A/B18A	main	30	f	f	240
6	subpanel	15	f	f	120
2	subpanel	20	f	f	120
7	subpanel	20	f	f	120
11	subpanel	15	f	t	120
12	subpanel	15	f	t	120
B6A	main	15	f	t	120
A27B	main	15	f	t	120
B24A	main	15	f	t	120
B26A	main	15	f	t	120
A19B	main	15	f	t	120
\.


--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.floors (uid) FROM stdin;
basement
downstairs
upstairs
attic
\.


--
-- Data for Name: interface_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.interface_types (short_name) FROM stdin;
switch
ceiling fixture
outlet
vent fan
ceiling fan
light fixture
wire
outlet (half)
switch (one of several)
junction box
gfci outlet
appliance
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.interfaces (space, location_in_space, circuit, interface_type, grounded, notes, rewired, uid) FROM stdin;
kitchen	east wall of extension, north of counters	8	outlet	t	plug updated, wiring looks modern	f	1
utility room	east wall upper	B4A	switch	t	furnace safety off switch	f	3
basement landing	south wall	B26A	outlet	t	in formerly water damaged area; junction box replaced	t	5
laundry	ceiling	B26A	ceiling fixture	t	bare-bulb fixture replaced with newer bare-bulb fixture	f	6
living room (south)	northeast wall 	A25B	outlet	t	\N	f	7
kitchen	dishwasher	3	wire	t	\N	f	8
sewing room	west wall	\N	outlet	\N	fully disassembled. Will be difficult to put back in this location.	t	9
downstairs landing	ceiling	12	ceiling fixture	t	\N	t	10
basement main room	south wall, north of closet (bottom switch)	B20A	switch	\N	controls half of overhead lights	f	11
basement main room	south wall, north of closet (top switch)	B22A	switch	\N	controls half of overhead lights	f	12
sewing room	ceiling	B6A	ceiling fixture	\N	bare wire now	t	13
sewing room	east wall (north)	B6A	outlet	t	new!	t	14
office	ceiling	A27B	ceiling fixture	t	new junction and fixture installed	t	15
laundry	west wall	B26A	outlet	t	should be GFCI!	f	16
basement main room	north wall west of door	4	outlet	t	chest freezer	f	17
kitchen	south of sink, over counter	6	outlet	t	should be GFCI	f	18
kitchen	north of sink, over counter	8	outlet	t	should be GFCI	f	19
front porch	ceiling	A27B	light fixture	t	newly replaced; controlled by switch inside door	t	20
downstairs landing	west wall by front door, middle switch	12	switch (one of several)	t	3-way switch; controls ceiling light	t	21
basement back room (west)	east wall	10	outlet	t	\N	f	22
bedroom	east wall behind dresser	5	outlet	t	runs through vent	f	23
downstairs landing	west wall by front door, north switch	A27B	switch (one of several)	t	3-way switch; controls ceiling light in upstairs landing	t	24
kitchen	south of stove, over counter	8	outlet	t	\N	f	25
basement main room	west wall (north)	B22A	outlet	t	\N	f	26
office	east wall	A27B	outlet	t	end of the circuit	f	27
back yard	over bay window	8	light fixture	t	has not worked yet; suspect it's activated by the third switch inside the door. Suspect circuit 8	f	28
front porch	ceiling	\N	outlet	f	completely removed	t	29
basement back room (east)	south wall	8	switch	t	\N	f	30
office	north wall	A27B	outlet	t	new wires comes from attic, old grounded wire extends south to outlet on east wall	t	31
basement back room (west)	east wall near entrance	1	switch	t	\N	f	32
basement main room	west wall (south)	B22A	outlet	t	replaced outlet 2025-11-23; ground wired to box; too short to wire to plug, but connection to box appears to be grounding it	f	33
living room (north)	ceiling	11	ceiling fan	t	disconnected by deconstructing switch	t	34
living room (north)	east wall near door to kitchen	11	switch	t	deconstructed	t	35
kitchen	ceiling, south over main kitchen	11	light fixture	t	\N	t	36
kitchen	west wall, south side	11	switch	t	\N	t	37
utility room	ceiling	A19B	junction box	t	new box. Added here on the way to outlets in the living room to potentially power other stuff in utility room later	t	38
bedroom	center of ceiling	12	ceiling fixture	t	\N	t	39
upstairs landing	north wall outside bathroom (west switch)	12	switch (one of several)	t	3-way switch	t	40
upstairs landing	ceiling	A27B	ceiling fixture	t	switched at top and bottom of stairs	t	41
living room (north)	southwest baseboard	A19B	outlet	t	Formerly K+T, fully replaced on new circuit; this one is powered from the outlet a few inches south of it	t	42
basement back room (west)	north wall	10	outlet	t	within water damage zone	f	43
basement back room (west)	east wall near entrance	1	light fixture	\N	\N	f	44
basement back room (east)	below panel	1	outlet	t	\N	f	45
basement back room (west)	south wall	10	outlet	t	within water damage zone	f	46
laundry	east wall	B28A/B30A	outlet	t	\N	f	47
basement main room	ceiling (west wide)	B22A	light fixture	\N	west-side cluster of embedded ceiling lights	f	48
basement main room	ceiling (east side)	B20A	light fixture	\N	east-side cluster of embedded ceiling lights	f	49
basement main room	south wall, north of cedar closet	B20A	outlet	t	\N	f	50
basement main room	north wall east of door	8	outlet	t	\N	f	51
kitchen	east wall south of counter, behind fridge	9	outlet	t	\N	f	52
living room (north)	east wall	5	outlet	t	runs through vent	f	53
kitchen	north wall below bay window	8	outlet	t	\N	f	55
utility room	ceiling	B22A	ceiling fixture	t	\N	f	56
back yard	on south side (north wall of house)	8	outlet	t	needs GFCI protection and weatherproof cover	f	57
kitchen	north of stove (top plug)	6	outlet (half)	t	\N	f	58
kitchen	behind stove	B16A/B18A	outlet	t	big stove outlet	f	59
back porch	over the door	8	light fixture	\N	controlled by switch inside door	f	60
upstairs bathroom	south wall	11	gfci outlet	t	newly replaced	t	61
upstairs bathroom	south wall	11	switch	t	two switches control lights and vent fan	f	62
basement stairs	east side of middle landing	B24A	switch	t	double switch; controls light at bottom of stairs and light outside side door	f	63
office	west wall	A27B	switch	t	new!	t	64
kitchen	north of stove (bottom plug)	10	outlet (half)	t	\N	f	65
basement landing	ceiling	B24A	light fixture	t	newly installed junction box replaced previous rat's nest	t	66
side walkway	west wall over door	B24A	light fixture	t	ground wire is not actually connected to fixture ground though	f	67
kitchen	ceiling, north over extension	8	light fixture	t	fixture replaced with chandelier	f	68
basement landing	south wall	B26A	switch	t	controls laundry room lights	t	70
sewing room	east wall (south)	B6A	outlet	t	new!	t	72
basement bathroom	ceiling of shower	B26A	ceiling fixture	t	replaced with ill-fitting LED fixture. Has it's own little junction box up there.	t	4
basement landing	north wall	A19B	light fixture	f	formerly powered by ungrounded lamp wire from cedar closet; modern wiring now	t	69
basement bathroom	ceiling	B26A	ceiling fixture	t	replaced with new simple fixture	t	54
basement landing	west wall	B26A	switch	t	controls bathroom lights and fan	t	71
basement main room	ceiling (west side)	B22A	junction box	t	big hot sloppy mess, but at least I could disconnect some K+T wires from it	\N	73
basement main room	ceiling (east side)	B20A	junction box	t	big hot sloppy mess	\N	74
office	west wall near vent	A27B	outlet	t	newly wired	t	75
kitchen	west wall near door to back porch	8	switch	t	triple switch, one controls outside light, one the light in the extension, one I think controls the flood light over the back yard	f	76
upstairs bathroom	over mirror	11	light fixture	t	\N	f	77
upstairs bathroom	ceiling	11	light fixture	\N	wired together with vent fan - same switch	f	78
upstairs landing	north wall, top of stairs	11	outlet	t	newly installed	t	79
utility room	near door	B8A/B10A	appliance	t	water heater	f	80
upstairs bathroom	top of north wall	11	vent fan	t	wired together with ceiling light - same switch; came that way	f	81
attic	northish, above the fluff	12	outlet	t	new! Unsure what the code is for spaces like this...	t	82
utility room	east wall lower	B22A	switch	t	\N	f	83
living room (south)	southeast wall	A27B	outlet	t	newly upgraded!	t	84
basement back room (west)	west wall	10	outlet	t	within water damage zone	f	85
basement back room (west)	north wall	10	wire	\N	wire coming out of wall; does not seem to be live	f	86
front yard	west of porch	A21B/A23B	appliance	t	air conditioner	f	87
sewing room	east wall	B6A	switch	t	rewired, moved from behind door	t	88
kitchen	over stove	10	vent fan	t	also has lights	f	89
cedar closet	above door	B22A	light fixture	\N	not up to code as a bare-bulb fixture	f	90
basement landing	north wall	B22A	outlet	t	used by aquarium	f	92
basement back room (east)	south wall	8	outlet	t	\N	f	93
basement back room (east)	north wall	1	outlet	t	\N	f	94
basement back room (east)	south wall	8	light fixture	\N	\N	f	95
bedroom	east wall by door	12	switch	t	replaced	t	96
upstairs landing	north wall outside bathroom (east switch)	A27B	switch (one of several)	t	3-way switch	t	97
downstairs landing	west wall by kitchen door	\N	switch	\N	is just a hole now	t	98
downstairs landing	west wall by front door, south switch	A27B	switch (one of several)	t	controls front porch light	t	99
living room (south)	northwest baseboard	A19B	outlet	t	formerly K+t, fully replaced and rewired. Powered from junction box in the utility room ceiling	t	100
basement stairs	top of stairs, west wall	A19B	switch	t	new switch box; formerly controlled aquarium plug; k + t wires and sketchy-ass junction box completely removed	t	2
basement bathroom	ceiling	B26A	vent fan	t	new	t	101
basement bathroom	above mirror	\N	wire	t	dangling wire, not connected. Is inserted in junction box with powered switches though	t	91
\.


--
-- Data for Name: panels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.panels (short_name, description, notes, circuit) FROM stdin;
main	\N	\N	\N
subpanel	\N	\N	B12A/B14A
\.


--
-- Data for Name: spaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spaces (short_name, floor, description) FROM stdin;
office	upstairs	blue room
sewing room	upstairs	orange room
bedroom	upstairs	green room
upstairs bathroom	upstairs	\N
basement bathroom	basement	\N
laundry	basement	\N
kitchen	downstairs	\N
living room (north)	downstairs	\N
living room (south)	downstairs	\N
coat closet	downstairs	\N
front porch	downstairs	I guess this is a "room" now
basement landing	basement	shared tiled area at base of stairs
basement stairs	basement	\N
upstairs landing	upstairs	"hallway"-like object
downstairs landing	downstairs	another hallway-like object
back porch	downstairs	\N
back yard	downstairs	\N
basement back room (east)	basement	the smaller one with the panel
basement back room (west)	basement	the larger one with the water damage
basement main room	basement	the part with the laminate flooring
cedar closet	basement	the whole closet really, including the antecloset
side walkway	downstairs	outside space accessible from side door
utility room	basement	has furnace, etc
front yard	downstairs	does not include the porch
attic	attic	\N
\.


--
-- Data for Name: wires; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wires (connects_from, connects_to, gauge, ground, notes, conductors) FROM stdin;
38	2	14	t	\N	2
2	69	14	t	switched	2
71	101	14	t	\N	2
71	91	14	t	\N	2
71	54	14	t	\N	2
71	4	14	t	\N	2
5	71	14	t	\N	2
\.


--
-- Name: interfaces_uid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.interfaces_uid_seq', 101, true);


--
-- Name: circuits circuits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circuits
    ADD CONSTRAINT circuits_pkey PRIMARY KEY (uid);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (uid);


--
-- Name: interface_types interface_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interface_types
    ADD CONSTRAINT interface_types_pkey PRIMARY KEY (short_name);


--
-- Name: interfaces interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (space, location_in_space, interface_type);


--
-- Name: panels panels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_pkey PRIMARY KEY (short_name);


--
-- Name: spaces rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (short_name);


--
-- Name: wires wires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_pkey PRIMARY KEY (connects_from, connects_to);


--
-- Name: interfaces_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX interfaces_uid_idx ON public.interfaces USING btree (uid);


--
-- Name: circuits circuits_panel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circuits
    ADD CONSTRAINT circuits_panel_fkey FOREIGN KEY (panel) REFERENCES public.panels(short_name);


--
-- Name: interfaces interfaces_circuit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_circuit_fkey FOREIGN KEY (circuit) REFERENCES public.circuits(uid);


--
-- Name: interfaces interfaces_interface_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_interface_type_fkey FOREIGN KEY (interface_type) REFERENCES public.interface_types(short_name);


--
-- Name: interfaces interfaces_room_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_room_fkey FOREIGN KEY (space) REFERENCES public.spaces(short_name);


--
-- Name: panels panels_circuit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_circuit_fkey FOREIGN KEY (circuit) REFERENCES public.circuits(uid);


--
-- Name: spaces rooms_floor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT rooms_floor_fkey FOREIGN KEY (floor) REFERENCES public.floors(uid);


--
-- Name: wires wires_connects_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_connects_from_fkey FOREIGN KEY (connects_from) REFERENCES public.interfaces(uid);


--
-- Name: wires wires_connects_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_connects_to_fkey FOREIGN KEY (connects_to) REFERENCES public.interfaces(uid);


--
-- PostgreSQL database dump complete
--

\unrestrict mTnNEUFR5XRXaE4NGSdOLw6WwIKz4jNVR8eXffFLvqobqZx8ei5fUQ2CDtIBAgK

