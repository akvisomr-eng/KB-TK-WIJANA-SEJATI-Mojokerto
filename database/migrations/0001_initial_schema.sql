BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE public.app_role AS ENUM ('superadmin', 'principal', 'admin_school', 'teacher', 'finance', 'hr', 'parent');
CREATE TYPE public.admission_status AS ENUM ('new', 'contacted', 'visit_scheduled', 'documents_pending', 'accepted', 'enrolled', 'declined');
CREATE TYPE public.attendance_status AS ENUM ('present', 'sick', 'excused', 'absent');

CREATE TABLE public.app_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_subject text NOT NULL UNIQUE,
  full_name text NOT NULL,
  email text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.user_roles (
  user_id uuid NOT NULL REFERENCES public.app_users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  assigned_by uuid REFERENCES public.app_users(id),
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, role)
);

CREATE TABLE public.academic_years (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL UNIQUE,
  starts_on date NOT NULL,
  ends_on date NOT NULL,
  is_current boolean NOT NULL DEFAULT false,
  CHECK (ends_on >= starts_on)
);
CREATE UNIQUE INDEX one_current_academic_year ON public.academic_years (is_current) WHERE is_current;

CREATE TABLE public.classrooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year_id uuid NOT NULL REFERENCES public.academic_years(id),
  name text NOT NULL,
  program text NOT NULL CHECK (program IN ('KB', 'TK')),
  teacher_user_id uuid REFERENCES public.app_users(id),
  capacity integer CHECK (capacity IS NULL OR capacity > 0),
  UNIQUE (academic_year_id, name)
);

CREATE TABLE public.guardians (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  phone text,
  email text,
  relationship_to_child text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_number text UNIQUE,
  full_name text NOT NULL,
  birth_date date,
  status text NOT NULL DEFAULT 'applicant' CHECK (status IN ('applicant', 'active', 'graduated', 'inactive')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.student_guardians (
  student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  guardian_id uuid NOT NULL REFERENCES public.guardians(id) ON DELETE CASCADE,
  is_primary boolean NOT NULL DEFAULT false,
  PRIMARY KEY (student_id, guardian_id)
);

CREATE TABLE public.enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id),
  classroom_id uuid NOT NULL REFERENCES public.classrooms(id),
  enrolled_on date NOT NULL DEFAULT CURRENT_DATE,
  ended_on date,
  CHECK (ended_on IS NULL OR ended_on >= enrolled_on),
  UNIQUE (student_id, classroom_id)
);

CREATE TABLE public.admission_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_name text,
  program_interest text NOT NULL CHECK (program_interest IN ('KB', 'TK', 'belum_tentukan')),
  guardian_name text NOT NULL,
  guardian_phone text,
  guardian_email text,
  status public.admission_status NOT NULL DEFAULT 'new',
  follow_up_at timestamptz,
  assigned_to uuid REFERENCES public.app_users(id),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.student_attendance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES public.students(id),
  classroom_id uuid NOT NULL REFERENCES public.classrooms(id),
  attendance_date date NOT NULL,
  status public.attendance_status NOT NULL,
  note text,
  recorded_by uuid NOT NULL REFERENCES public.app_users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, attendance_date)
);

CREATE TABLE public.chart_of_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  account_type text NOT NULL CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense')),
  parent_id uuid REFERENCES public.chart_of_accounts(id),
  is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE public.journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_number text NOT NULL UNIQUE,
  entry_date date NOT NULL,
  description text NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'posted', 'void')),
  created_by uuid NOT NULL REFERENCES public.app_users(id),
  approved_by uuid REFERENCES public.app_users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  posted_at timestamptz
);

CREATE TABLE public.journal_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_entry_id uuid NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
  account_id uuid NOT NULL REFERENCES public.chart_of_accounts(id),
  description text,
  debit numeric(14,2) NOT NULL DEFAULT 0 CHECK (debit >= 0),
  credit numeric(14,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
  CHECK ((debit > 0 AND credit = 0) OR (credit > 0 AND debit = 0))
);
CREATE INDEX journal_lines_entry_idx ON public.journal_lines(journal_entry_id);

CREATE TABLE public.employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.app_users(id),
  employee_number text UNIQUE,
  full_name text NOT NULL,
  employment_type text,
  started_on date,
  ended_on date,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ended_on IS NULL OR started_on IS NULL OR ended_on >= started_on)
);

CREATE TABLE public.leave_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.employees(id),
  starts_on date NOT NULL,
  ends_on date NOT NULL,
  reason text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
  reviewed_by uuid REFERENCES public.app_users(id),
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_on >= starts_on)
);

CREATE TABLE public.payroll_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  period_start date NOT NULL,
  period_end date NOT NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'approved', 'paid', 'void')),
  created_by uuid NOT NULL REFERENCES public.app_users(id),
  approved_by uuid REFERENCES public.app_users(id),
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (period_end >= period_start),
  UNIQUE (period_start, period_end)
);

CREATE TABLE public.payroll_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payroll_run_id uuid NOT NULL REFERENCES public.payroll_runs(id) ON DELETE CASCADE,
  employee_id uuid NOT NULL REFERENCES public.employees(id),
  base_salary numeric(14,2) NOT NULL DEFAULT 0 CHECK (base_salary >= 0),
  allowances numeric(14,2) NOT NULL DEFAULT 0 CHECK (allowances >= 0),
  deductions numeric(14,2) NOT NULL DEFAULT 0 CHECK (deductions >= 0),
  net_pay numeric(14,2) GENERATED ALWAYS AS (base_salary + allowances - deductions) STORED,
  UNIQUE (payroll_run_id, employee_id)
);

CREATE TABLE public.audit_log (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_user_id uuid REFERENCES public.app_users(id),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text,
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX audit_log_created_at_idx ON public.audit_log(created_at DESC);
CREATE INDEX admission_leads_status_idx ON public.admission_leads(status, created_at DESC);
CREATE INDEX student_attendance_date_idx ON public.student_attendance(attendance_date, classroom_id);

-- SECURITY NOTE: This migration intentionally does not expose database access to browsers.
-- Apply only after reviewing roles, server-side authorization, and the production backup plan.
-- Do not insert real child/employee data into development environments.

COMMIT;
